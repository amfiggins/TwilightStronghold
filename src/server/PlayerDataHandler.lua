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

local PlayerDataHandler = {}
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_" .. GameConfig.GAME_VERSION)

-- Default Data Schema
local DEFAULT_DATA = {
    Stats = {
        Rubies = 0, -- Lobby Currency (from selling fish/ores)
        Diamonds = 0, -- Premium/Survival Currency (from 99 Nights)
        Level = 1,
        XP = 0
    },
    Inventory = {
        -- Format: { Content = "wood", Qty = 10 }, { ItemId = "void_sword", GUID = "..." }
    },
    Loadout = {
        Weapon = nil, -- Usage: ItemId (e.g. "void_sword")
        BaseKit = nil
    },
    CodesRedeemed = {}
}

-- Runtime session cache
local sessionData = {}
-- Runtime inventory lookup cache: [UserId] = { [ItemId] = slotIndex }
-- Optimization: Maps ItemId to the *first* index in inventory for O(1) checks.
local sessionInventoryLookup = {}

-- Helper: Deep Copy Table
local function deepCopy(orig)
    local original_type = type(orig)
    local copy
    if original_type == 'table' then
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
    if not data then return end

    local lookup = {}
    for i, slot in ipairs(data.Inventory) do
        -- Only store the first occurrence to preserve "first found" logic
        if not lookup[slot.ItemId] then
            lookup[slot.ItemId] = i
        end
    end
    sessionInventoryLookup[userId] = lookup
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
        while true do
            local players = Players:GetPlayers()
            local playerCount = #players

            if playerCount > 0 then
                -- Stagger saves over 60 seconds to prevent DataStore throttling
                local interval = 60 / playerCount
                for _, player in ipairs(players) do
                    task.spawn(function()
                        PlayerDataHandler.Save(player)
                    end)
                    task.wait(interval)
                end
            else
                task.wait(60)
            end
        end
    end)
end

function PlayerDataHandler.OnPlayerAdded(player)
    local userId = player.UserId
    local key = "Player_" .. userId
    
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(key)
    end)
    
    if success then
        data = data or deepCopy(DEFAULT_DATA)
        reconcile(data, DEFAULT_DATA)
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
    PlayerDataHandler.Save(player)
    sessionData[player.UserId] = nil
    sessionInventoryLookup[player.UserId] = nil
end

function PlayerDataHandler.Save(player)
    local userId = player.UserId
    local data = sessionData[userId]
    
    if not data then return end
    
    local key = "Player_" .. userId
    
    local success, err = pcall(function()
        PlayerDataStore:SetAsync(key, data)
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

-- Public API to Add Item
function PlayerDataHandler.AddItem(player, itemId, quantity)
    local userId = player.UserId
    local data = sessionData[userId]
    if not data then return false, "NoData" end
    
    -- Ensure lookup exists (safety)
    if not sessionInventoryLookup[userId] then
        rebuildLookup(userId)
    end
    local lookup = sessionInventoryLookup[userId]

    quantity = quantity or 1
    
    local itemDef = GameConfig.Items[itemId]
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
            if #data.Inventory >= GameConfig.INVENTORY_CAPACITY then
                return false, "InventoryFull"
            end
            table.insert(data.Inventory, { ItemId = itemId, Qty = quantity })
            -- Update Lookup
            lookup[itemId] = #data.Inventory
        end
    else
        -- Non-stackable logic: Items with unique GUIDs
        if #data.Inventory + quantity <= GameConfig.INVENTORY_CAPACITY then
            for _ = 1, quantity do
                table.insert(data.Inventory, {
                    ItemId = itemId,
                    Qty = 1,
                    GUID = HttpService:GenerateGUID(false)
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
    if not data then return false end
    
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
    if not data then return nil end

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
    if not data then return false end

    quantity = quantity or 1

    -- Optimization: Use Lookup Table to find slot (O(1))
    local lookup = sessionInventoryLookup[userId]
    local slotIndex = lookup and lookup[itemId]

    if not slotIndex then return false end -- Not found

    local slot = data.Inventory[slotIndex]
    local currentQty = slot.Qty or 1

    if currentQty < quantity then
        return false -- Not enough items
    end

    -- Deduct
    local newQty = currentQty - quantity
    if newQty <= 0 then
        -- Remove slot
        table.remove(data.Inventory, slotIndex)
        -- Indices shifted, we must rebuild lookup (O(N))
        rebuildLookup(userId)
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
    if not data then return false end
    
    -- Slot must be "Weapon" or "BaseKit" based on our schema
    if slot ~= "Weapon" and slot ~= "BaseKit" then return false end
    
    -- Verification: Does player own this item?
    if itemId and not PlayerDataHandler.GetItem(player, itemId) then
        return false
    end
    
    data.Loadout[slot] = itemId
    return true
end

return PlayerDataHandler
