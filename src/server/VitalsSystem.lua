--[[
    VitalsSystem.lua
    Survival-only. Ticks Hunger and Thirst decay every DECAY_INTERVAL seconds.
    When either hits 0, the player takes starvation/dehydration damage.
    Fires VitalsUpdate to each player whenever their vitals change so the
    client HUD can stay in sync without polling.

    Consume flow:
      Client fires EatItem(itemId) or DrinkItem(itemId)
      → VitalsSystem validates and delegates to PlayerDataHandler.ConsumeItem
      → fires VitalsUpdate back to the client with the new values
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local VitalsSystem = {}

-- ── Config ────────────────────────────────────────────────────────────────
local DECAY_INTERVAL = 5 -- seconds between decay ticks
local HUNGER_DECAY = 1 -- hunger lost per tick
local THIRST_DECAY = 2 -- thirst lost per tick (thirst drains faster)
local STARVATION_DAMAGE = 1 -- HP lost per tick when Hunger == 0
local DEHYDRATION_DAMAGE = 2 -- HP lost per tick when Thirst == 0
local CONSUME_COOLDOWN = 0.5 -- seconds between consume requests (anti-spam)

-- ── Remotes ───────────────────────────────────────────────────────────────
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local EatItemEvent = Instance.new("RemoteEvent")
EatItemEvent.Name = "EatItem"
EatItemEvent.Parent = Remotes

local DrinkItemEvent = Instance.new("RemoteEvent")
DrinkItemEvent.Name = "DrinkItem"
DrinkItemEvent.Parent = Remotes

-- Server → Client: fires whenever vitals change so the HUD can update.
local VitalsUpdateEvent = Instance.new("RemoteEvent")
VitalsUpdateEvent.Name = "VitalsUpdate"
VitalsUpdateEvent.Parent = Remotes

-- ── Internal state ────────────────────────────────────────────────────────
local lastConsumeAt = {} -- [UserId] = os.clock()

-- ── Helpers ───────────────────────────────────────────────────────────────
local function fireVitalsUpdate(player)
    local vitals = PlayerDataHandler.GetVitals(player)
    if vitals then
        VitalsUpdateEvent:FireClient(player, vitals)
    end
end

local function applyDecay(player)
    local vitals = PlayerDataHandler.GetVitals(player)
    if not vitals then
        return
    end

    local newHunger = PlayerDataHandler.SetVital(player, "Hunger", vitals.Hunger - HUNGER_DECAY)
    local newThirst = PlayerDataHandler.SetVital(player, "Thirst", vitals.Thirst - THIRST_DECAY)

    -- Starvation / dehydration damage
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        if newHunger == 0 then
            humanoid:TakeDamage(STARVATION_DAMAGE)
        end
        if newThirst == 0 then
            humanoid:TakeDamage(DEHYDRATION_DAMAGE)
        end
    end

    fireVitalsUpdate(player)
end

local function handleConsume(player, itemId)
    -- 🛡️ Sentinel: Validate itemId is a string before it propagates to table indexing to prevent thread crash DoS
    if type(itemId) ~= "string" then
        return
    end

    -- Rate limit
    local now = os.clock()
    if (now - (lastConsumeAt[player.UserId] or 0)) < CONSUME_COOLDOWN then
        return
    end
    lastConsumeAt[player.UserId] = now

    -- Delegate to PlayerDataHandler (validates ownership, type, removes item)
    local success, reason = PlayerDataHandler.ConsumeItem(player, itemId)
    if success then
        fireVitalsUpdate(player)
    else
        -- Silently ignore invalid requests; don't warn to avoid log spam
        -- from a misbehaving client. Legitimate clients never hit this.
        if reason ~= "NotOwned" and reason ~= "NotConsumable" then
            warn(
                string.format(
                    "[VitalsSystem] ConsumeItem failed for %s (%s): %s",
                    player.Name,
                    tostring(itemId),
                    reason
                )
            )
        end
    end
end

-- ── Public API ────────────────────────────────────────────────────────────
function VitalsSystem.Init()
    -- EatItem and DrinkItem both route through the same handler since
    -- PlayerDataHandler.ConsumeItem accepts both Food and Drink types.
    EatItemEvent.OnServerEvent:Connect(handleConsume)
    DrinkItemEvent.OnServerEvent:Connect(handleConsume)

    -- Send initial vitals to each player when they join (so the HUD
    -- doesn't show stale values on first load).
    Players.PlayerAdded:Connect(function(player)
        -- Wait briefly for PlayerDataHandler to finish loading the session.
        task.wait(1)
        fireVitalsUpdate(player)
    end)

    -- Decay loop: stagger players across the interval to avoid a spike
    -- every DECAY_INTERVAL seconds when many players are online.
    task.spawn(function()
        local playerIndex = 1
        while true do
            local allPlayers = Players:GetPlayers()
            local count = #allPlayers
            if count > 0 then
                local interval = DECAY_INTERVAL / count
                if playerIndex > count then
                    playerIndex = 1
                end
                local player = allPlayers[playerIndex]
                if player then
                    applyDecay(player)
                end
                playerIndex = playerIndex + 1
                task.wait(interval)
            else
                playerIndex = 1
                task.wait(DECAY_INTERVAL)
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        lastConsumeAt[player.UserId] = nil
    end)

    print("[VitalsSystem] Initialized.")
end

return VitalsSystem
