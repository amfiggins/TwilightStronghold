--[[
    ResourceManager.lua
    Handles server-side validation of resource gathering and awards items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ResourceManager = {}

-- Create Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder", ReplicatedStorage)
RemotesFolder.Name = "Remotes"

local GatherEvent = Instance.new("RemoteEvent", RemotesFolder)
GatherEvent.Name = "GatherResource"

function ResourceManager.Init()
    GatherEvent.OnServerEvent:Connect(ResourceManager.OnGatherRequest)
    print("[ResourceManager] Initialized. Listening for Gather events.")
end

function ResourceManager.OnGatherRequest(player, resourceId)
    -- 1. Validation Logic
    -- In a real game, we'd check distance between player and resourceId, cooldowns, and tool equipped.
    -- For this MVP Prototype, we trust the client's "Success" for now but log it.
    
    -- Mock Resource Data for testing
    local mockLoot = {
        ["Tree"] = { Item = "wood_log", Min = 1, Max = 3, RareItem = "golden_wood" },
        ["Rock"] = { Item = "stone_ore", Min = 1, Max = 2 },
        ["Lake"] = { Item = "raw_fish", Min = 1, Max = 1 }
    }
    
    -- Determine what they got (Simulating logic)
    -- In reality, resourceId would map to a specific node type
    local nodeType = "Tree" -- Fallback

    if typeof(resourceId) == "Instance" then
        nodeType = resourceId.Name
    end

    local drop = mockLoot[nodeType]

    if not drop then
        warn("[ResourceManager] Unknown resource type: " .. tostring(nodeType))
        return
    end
    
    -- Logic: Roll for Rarity (The "Fisch" mechanic)
    local roll = math.random(1, 100)
    local itemAwarded = drop.Item
    local qty = math.random(drop.Min, drop.Max)
    
    if roll > 95 and drop.RareItem then
        itemAwarded = drop.RareItem -- Rare drop!
    end
    
    -- Verify Inventory Cap? (Skip for now)
    
    -- Add Item
    local success = PlayerDataHandler.AddItem(player, itemAwarded, qty)
    
    if success then
        print(string.format("[ResourceManager] Awarded %s x%d to %s", itemAwarded, qty, player.Name))
        -- Optional: Send feedback back to client
    end
end

return ResourceManager
