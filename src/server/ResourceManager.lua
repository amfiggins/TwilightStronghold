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

function ResourceManager.OnGatherRequest(player, resourceNode)
    -- 1. Validation Logic
    if typeof(resourceNode) ~= "Instance" then
        warn("[ResourceManager] Invalid resource node received.")
        return
    end

    -- Determine what they got
    local resourceType = resourceNode.Name
    local drop = GameConfig.Resources[resourceType]

    if not drop then
        warn(string.format("[ResourceManager] Unknown resource type: %s", resourceType))
        return
    end
    
    -- Logic: Roll for Rarity (The "Fisch" mechanic)
    local roll = math.random(1, 100)
    local itemAwarded = drop.Item
    local qty = math.random(drop.Min, drop.Max)
    
    -- Rare drop logic override for Tree/Wood
    if itemAwarded == "wood_log" and roll > 95 then
        itemAwarded = "golden_wood" -- Rare drop!
    end
    
    -- Verify Inventory Cap? (Skip for now)
    
    -- Add Item
    local success = PlayerDataHandler.AddItem(player, itemAwarded, qty)
    
    if success then
        print(string.format("[ResourceManager] Awarded %s x%d to %s", itemAwarded, qty, player.Name))
        -- Notify client of successful gathering
        GatherEvent:FireClient(player, itemAwarded, qty)
    end
end

return ResourceManager
