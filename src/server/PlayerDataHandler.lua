--[[
    PlayerDataHandler.lua
    Handles loading, saving, and managing player data using Roblox DataStores.
    Includes session locking and autosave functionality.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

local PlayerDataHandler = {}
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_" .. GameConfig.GAME_VERSION)

-- Default Data Schema
local DEFAULT_DATA = {
    Stats = {
        Rubies = 0, -- Lobby Currency (from selling fish/ores)
        Diamonds = 0, -- Premium/Survival Currency (from 99 Nights)
        Level = 1,
        XP = 0,
    },
    Inventory = {
        -- Format: { ItemId = "wood", Qty = 10 }, { ItemId = "void_sword", GUID = "..." }
        -- New players spawn with a starter bag and a wooden sword so they
        -- can fight on Day 1 of Survival.
        { ItemId = "starter_bag", Qty = 1 },
        { ItemId = "wooden_sword", Qty = 1 },
    },
    Loadout = {
        -- Players equip via the LoadoutUI. We don't preset a Weapon here
        -- because existing accounts that pre-date the wooden_sword wouldn't
        -- actually have one in their inventory after reconcile().
        Weapon = nil,
        BaseKit = nil,
        Bag = "starter_bag",
    },
    CodesRedeemed = {},
}

-- Runtime session cache
local sessionData = {}
-- Runtime inventory lookup cache: [UserId] = { [ItemId] = slotIndex }
-- Optimization: Maps ItemId to the *first* index in inventory for O(1) checks.
local sessionInventoryLookup = {}

local GET_DATA_COOLDOWN = 1.0
local lastGetDataTimes = {}

-- Helper: Deep Copy Table
local function deepCopy(orig)
    local original_type = type(orig)
    local copy
    if original_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Helper: Reconcile with default data (fills missing keys)
local function reconcile(target, template)
    for k, v in pairs(template) do
        if target[k] == nil then
            if type(v) == "table" then
                target[k] = deepCopy(v)
            else
                target[k] = v
            end
        elseif type(target[k]) == "table" and type(v) == "table" then
            reconcile(target[k], v)
        end
    end
end

-- Helper: Rebuild Lookup for a user (O(N)) - Called when indices shift
local function rebuildLookup(userId)
    local data = sessionData[userId]
    if not data then
        return
    end

    local lookup = {}
    for i, slot in ipairs(data.Inventory) do
        -- Only store the first occurrence to preserve "first found" logic
        if not lookup[slot.ItemId] then
            lookup[slot.ItemId] = i
        end
    end
    sessionInventoryLookup[userId] = lookup
end

-- ── Cross-server session locking ──────────────────────────────────────────
-- Prevents two Roblox servers from loading + writing the same player key
-- concurrently (e.g., during a Lobby → Survival teleport handoff).
--
-- Locks older than this are considered abandoned (server crash, force-shutdown)
-- and the next server to load can take over.
local SESSION_LOCK_STALE_SECONDS = 600
-- During a teleport handoff, the source server's final save may not have
-- landed yet. We retry this many times, this many seconds apart.
local SESSION_LOCK_RETRY_SECONDS = 6
local SESSION_LOCK_RETRIES = 5

-- Acquire (or take over) the session lock for a key using UpdateAsync as
-- compare-and-swap.
-- Returns (true, dataWithoutLockMetadata) on success, (false, reason) on failure.
local function acquireSessionLock(store, key)
    local lastReason = "Unknown"

    for attempt = 1, SESSION_LOCK_RETRIES do
        local pcallSuccess, result = pcall(function()
            return store:UpdateAsync(key, function(oldData)
                local now = os.time()
                local existingLock = oldData and oldData._SessionLock

                if existingLock and existingLock.JobId ~= game.JobId then
                    local lockAge = now - (existingLock.LockTime or 0)
                    if lockAge < SESSION_LOCK_STALE_SECONDS then
                        -- Held by another live server. Returning nil from
                        -- UpdateAsync's transformer aborts the write so we
                        -- don't bump a key we don't own.
                        return nil
                    end
                    warn(
                        string.format(
                            "[Data] Taking over stale session lock for %s (age %ds, prev JobId %s)",
                            key,
                            lockAge,
                            tostring(existingLock.JobId)
                        )
                    )
                end

                oldData = oldData or {}
                oldData._SessionLock = { JobId = game.JobId, LockTime = now }
                return oldData
            end)
        end)

        if pcallSuccess and result ~= nil then
            -- Strip the lock metadata from the in-memory copy so reconcile()
            -- and Save() don't have to special-case it.
            local data = table.clone(result)
            data._SessionLock = nil
            return true, data
        end

        if not pcallSuccess then
            lastReason = tostring(result)
            warn(
                string.format(
                    "[Data] acquireSessionLock failed for %s (attempt %d/%d): %s",
                    key,
                    attempt,
                    SESSION_LOCK_RETRIES,
                    lastReason
                )
            )
        else
            lastReason = "LockedByAnotherServer"
        end

        if attempt < SESSION_LOCK_RETRIES then
            task.wait(SESSION_LOCK_RETRY_SECONDS)
        end
    end

    return false, lastReason
end

-- Release the session lock by clearing the lock fields. Used when a player
-- leaves cleanly so other servers can immediately take over the key.
local function releaseSessionLock(store, key, finalData)
    local pcallSuccess, err = pcall(function()
        store:UpdateAsync(key, function(oldData)
            -- Even if oldData is nil (DataStore wipe between writes, vanishingly
            -- rare), we still want to commit the player's final data.
            local payload = finalData or oldData or {}
            payload._SessionLock = nil
            return payload
        end)
    end)

    if not pcallSuccess then
        warn(string.format("[Data] releaseSessionLock failed for %s: %s", key, tostring(err)))
        return false
    end
    return true
end

function PlayerDataHandler.Init()
    -- Setup Remotes
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not Remotes then
        Remotes = Instance.new("Folder")
        Remotes.Name = "Remotes"
        Remotes.Parent = ReplicatedStorage
    end

    local GetPlayerData = Instance.new("RemoteFunction")
    GetPlayerData.Name = "GetPlayerData"
    GetPlayerData.Parent = Remotes

    GetPlayerData.OnServerInvoke = function(player)
        local now = os.clock()
        local lastRequest = lastGetDataTimes[player.UserId] or 0
        if (now - lastRequest) < GET_DATA_COOLDOWN then
            return nil, "RateLimited"
        end
        lastGetDataTimes[player.UserId] = now

        local start = os.clock()
        local data = PlayerDataHandler.Get(player)
        -- Poll until data exists or timeout (5 seconds)
        while not data and (os.clock() - start) < 5 do
            task.wait(0.1)
            data = PlayerDataHandler.Get(player)
        end
        return data
    end

    Players.PlayerAdded:Connect(PlayerDataHandler.OnPlayerAdded)
    Players.PlayerRemoving:Connect(PlayerDataHandler.OnPlayerRemoving)

    -- Autosave Loop
    task.spawn(function()
        local playerIndex = 1
        while true do
            local players = Players:GetPlayers()
            local playerCount = #players

            if playerCount > 0 then
                -- Stagger saves over 60 seconds to prevent DataStore throttling
                local interval = 60 / playerCount

                -- Wrap index if it exceeds current player count
                if playerIndex > playerCount then
                    playerIndex = 1
                end

                local player = players[playerIndex]
                if player then
                    task.spawn(function()
                        PlayerDataHandler.Save(player)
                    end)
                end

                playerIndex = playerIndex + 1
                task.wait(interval)
            else
                playerIndex = 1
                task.wait(5)
            end
        end
    end)

    -- BindToClose: final flush before the server shuts down. Roblox gives us
    -- 30 seconds; we save all sessions in parallel and wait up to 25s for them.
    -- Skip in Studio because BindToClose blocks Play Solo for the full timeout.
    if not RunService:IsStudio() then
        game:BindToClose(function()
            local players = Players:GetPlayers()
            if #players == 0 then
                return
            end

            print(string.format("[Data] BindToClose: flushing %d players", #players))

            local pending = #players
            local doneSignal = Instance.new("BindableEvent")

            for _, player in ipairs(players) do
                task.spawn(function()
                    -- releaseLock=true so other servers can take over immediately.
                    PlayerDataHandler.Save(player, true)
                    pending = pending - 1
                    if pending == 0 then
                        doneSignal:Fire()
                    end
                end)
            end

            -- Wait up to 25s for saves to finish
            local timeoutThread = task.delay(25, function()
                if pending > 0 then
                    warn(string.format("[Data] BindToClose: %d saves did not complete in time", pending))
                    doneSignal:Fire()
                end
            end)

            doneSignal.Event:Wait()
            task.cancel(timeoutThread)
        end)
    end
end

function PlayerDataHandler.OnPlayerAdded(player)
    local userId = player.UserId
    local key = "Player_" .. userId

    -- Acquire the cross-server session lock. This both fetches the data and
    -- atomically marks the key as owned by this JobId.
    local success, data = acquireSessionLock(PlayerDataStore, key)

    if success then
        -- Detect first-time players: empty result vs missing keys
        if not data or not next(data) then
            data = deepCopy(DEFAULT_DATA)
        end
        reconcile(data, DEFAULT_DATA)

        -- One-time migration: ensure every player has at least one Weapon
        -- in their inventory. Existing accounts pre-date the wooden_sword.
        local hasWeapon = false
        for _, slot in ipairs(data.Inventory) do
            local def = ItemDatabase.GetItem(slot.ItemId)
            if def and def.Type == "Weapon" then
                hasWeapon = true
                break
            end
        end
        if not hasWeapon then
            table.insert(data.Inventory, { ItemId = "wooden_sword", Qty = 1 })
        end

        sessionData[userId] = data

        -- Build Lookup Table
        rebuildLookup(userId)

        -- Setup Leaderstats (Visual Debug)
        local ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        ls.Parent = player

        local rubies = Instance.new("IntValue")
        rubies.Name = "Rubies"
        rubies.Value = data.Stats.Rubies
        rubies.Parent = ls

        local diamonds = Instance.new("IntValue")
        diamonds.Name = "Diamonds"
        diamonds.Value = data.Stats.Diamonds
        diamonds.Parent = ls

        print(string.format("[Data] Loaded data for %s", player.Name))
    else
        warn(string.format("[Data] Failed to load data for %s: %s", player.Name, tostring(data)))
        -- Kick to prevent data loss or overwriting with empty data
        player:Kick("Failed to load data. Please rejoin.")
    end
end

function PlayerDataHandler.OnPlayerRemoving(player)
    -- Release the session lock as part of the final save so other servers
    -- can take over immediately on teleport handoff.
    PlayerDataHandler.Save(player, true)
    sessionData[player.UserId] = nil
    sessionInventoryLookup[player.UserId] = nil
    lastGetDataTimes[player.UserId] = nil
end

-- Save player data. If `releaseLock` is true, also clears the session lock so
-- another server can immediately take over the key (used on player leave).
function PlayerDataHandler.Save(player, releaseLock)
    local userId = player.UserId
    local data = sessionData[userId]

    if not data then
        return
    end

    local key = "Player_" .. userId

    if releaseLock then
        local ok = releaseSessionLock(PlayerDataStore, key, data)
        if ok then
            print(string.format("[Data] Saved data for %s (lock released)", player.Name))
        end
        return
    end

    -- Routine save: refresh the session lock at the same time so a long-lived
    -- session never looks stale to another server.
    local success, err = pcall(function()
        PlayerDataStore:UpdateAsync(key, function(oldData)
            -- Defensive: if a different server somehow has the lock, abort
            -- by returning nil rather than overwrite their data.
            local existingLock = oldData and oldData._SessionLock
            if existingLock and existingLock.JobId ~= game.JobId then
                local lockAge = os.time() - (existingLock.LockTime or 0)
                if lockAge < SESSION_LOCK_STALE_SECONDS then
                    warn(string.format("[Data] Refusing save for %s: lock held by another server", key))
                    return nil
                end
            end

            local payload = table.clone(data)
            payload._SessionLock = { JobId = game.JobId, LockTime = os.time() }
            return payload
        end)
    end)

    if success then
        print(string.format("[Data] Saved data for %s", player.Name))
    else
        warn(string.format("[Data] Failed to save data for %s: %s", player.Name, tostring(err)))
    end
end

-- Public API to get data
function PlayerDataHandler.Get(player)
    return sessionData[player.UserId]
end

-- Public API to Get Max Inventory Slots (based on equipped bag)
function PlayerDataHandler.GetMaxInventorySlots(player)
    local data = sessionData[player.UserId]
    if not data then
        return GameConfig.INVENTORY_CAPACITY
    end

    local bagId = data.Loadout.Bag
    if bagId then
        local bagItem = ItemDatabase.GetItem(bagId)
        if bagItem and bagItem.Capacity then
            return bagItem.Capacity
        end
    end

    return GameConfig.INVENTORY_CAPACITY
end

-- Public API to Add Item
function PlayerDataHandler.AddItem(player, itemId, quantity)
    local userId = player.UserId
    local data = sessionData[userId]
    if not data then
        return false, "NoData"
    end

    -- Ensure lookup exists (safety)
    if not sessionInventoryLookup[userId] then
        rebuildLookup(userId)
    end
    local lookup = sessionInventoryLookup[userId]
    quantity = quantity or 1
    if type(quantity) ~= "number" or quantity <= 0 or quantity ~= quantity or quantity == math.huge then
        return false, "InvalidQuantity"
    end

    local itemDef = ItemDatabase.GetItem(itemId)
    local isStackable = true
    if itemDef and itemDef.Stackable == false then
        isStackable = false
    end

    if isStackable then
        -- Check if item exists (Stacking logic for "Materials")
        -- Optimization: Use GetItem (which uses Lookup O(1))
        local slot = PlayerDataHandler.GetItem(player, itemId)

        if slot then
            slot.Qty = (slot.Qty or 1) + quantity
        else
            -- Not found, Add new slot
            if #data.Inventory >= PlayerDataHandler.GetMaxInventorySlots(player) then
                return false, "InventoryFull"
            end
            table.insert(data.Inventory, { ItemId = itemId, Qty = quantity })
            -- Update Lookup
            lookup[itemId] = #data.Inventory
        end
    else
        -- Non-stackable logic: Items with unique GUIDs
        if #data.Inventory + quantity <= PlayerDataHandler.GetMaxInventorySlots(player) then
            for _ = 1, quantity do
                table.insert(data.Inventory, {
                    ItemId = itemId,
                    Qty = 1,
                    GUID = HttpService:GenerateGUID(false),
                })
                -- Update Lookup (point to first one if not set)
                if not lookup[itemId] then
                    lookup[itemId] = #data.Inventory
                end
            end
        else
            return false, "InventoryFull"
        end
    end

    return true, "Success"
end

-- Public API to Add Currency
function PlayerDataHandler.AddCurrency(player, currencyType, amount)
    local data = sessionData[player.UserId]
    if not data then
        return false
    end

    if type(amount) ~= "number" or amount <= 0 or amount ~= amount or amount == math.huge then
        return false
    end

    if data.Stats[currencyType] then
        data.Stats[currencyType] = data.Stats[currencyType] + amount

        -- Update Leaderstats
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild(currencyType) then
            ls[currencyType].Value = data.Stats[currencyType]
        end
        return true
    end
    return false
end

-- Public API to Get Item
function PlayerDataHandler.GetItem(player, itemId)
    local userId = player.UserId
    local data = sessionData[userId]
    if not data then
        return nil
    end

    -- Optimization: Use Lookup Table (O(1))
    local lookup = sessionInventoryLookup[userId]
    if lookup and lookup[itemId] then
        return data.Inventory[lookup[itemId]]
    end

    return nil
end

-- Public API to Remove Item
function PlayerDataHandler.RemoveItem(player, itemId, quantity)
    local userId = player.UserId
    local data = sessionData[userId]
    if not data then
        return false
    end

    quantity = quantity or 1
    if type(quantity) ~= "number" or quantity <= 0 or quantity ~= quantity or quantity == math.huge then
        return false
    end

    -- Optimization: Use Lookup Table to find slot (O(1))
    local lookup = sessionInventoryLookup[userId]
    local slotIndex = lookup and lookup[itemId]

    if not slotIndex then
        return false
    end -- Not found

    local slot = data.Inventory[slotIndex]
    if not slot or slot.ItemId ~= itemId then
        -- Desync or invalid lookup
        return false
    end
    local currentQty = slot.Qty or 1

    if currentQty < quantity then
        return false -- Not enough items
    end

    -- Deduct
    local newQty = currentQty - quantity
    if newQty <= 0 then
        -- Remove slot efficiently (O(1) Swap-Remove) to avoid shifting array
        local lastIndex = #data.Inventory
        local lastItem = data.Inventory[lastIndex]

        if slotIndex == lastIndex then
            -- Removing the last item, no swap needed
            table.remove(data.Inventory, lastIndex)
            if lookup and lookup[itemId] == slotIndex then
                lookup[itemId] = nil
            end
        else
            -- Swap with last item
            data.Inventory[slotIndex] = lastItem
            table.remove(data.Inventory, lastIndex)

            -- Update Lookup for the moved item
            -- If the moved item was the primary instance (lookup pointed to lastIndex), update it
            if lookup and lookup[lastItem.ItemId] == lastIndex then
                lookup[lastItem.ItemId] = slotIndex
            end

            -- Update Lookup for the removed item
            if lookup and lookup[itemId] == slotIndex then
                -- We removed the primary instance.
                lookup[itemId] = nil

                -- Check if the moved item (now at slotIndex) is the same type, taking the spot
                if lastItem.ItemId == itemId then
                    lookup[itemId] = slotIndex
                else
                    -- Scan for new primary instance (Worst case O(N), but rare for stackables)
                    for i, item in ipairs(data.Inventory) do
                        if item.ItemId == itemId then
                            lookup[itemId] = i
                            break
                        end
                    end
                end
            end
        end
    else
        -- Update slot
        slot.Qty = newQty
        -- Lookup index remains valid
    end

    return true
end

-- Public API to Set Loadout
function PlayerDataHandler.SetLoadout(player, slot, itemId)
    local data = sessionData[player.UserId]
    if not data then
        return false
    end

    -- Slot must be "Weapon" or "BaseKit" or "Bag" based on our schema
    if slot ~= "Weapon" and slot ~= "BaseKit" and slot ~= "Bag" then
        return false
    end

    -- Verification: Does player own this item?
    if itemId and not PlayerDataHandler.GetItem(player, itemId) then
        return false
    end

    data.Loadout[slot] = itemId
    return true
end

return PlayerDataHandler
