--[[
    ResourceManager.lua
    Handles server-side validation of resource gathering and awards items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ResourceManager = {}

local MAX_GATHER_DISTANCE = 25 -- Maximum distance in studs to allow gathering

-- Create Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder", ReplicatedStorage)
RemotesFolder.Name = "Remotes"

local GatherEvent = Instance.new("RemoteEvent", RemotesFolder)
GatherEvent.Name = "GatherResource"

-- Mapping: Specific Node Name -> Generic Resource ID
local NODE_TYPE_MAPPING = {
    ["OakTree"] = "Tree",
    ["BirchTree"] = "Tree",
    ["PineTree"] = "Tree",
    ["Boulder"] = "Rock",
    ["Limestone"] = "Rock",
    ["Pond"] = "Lake",
    ["River"] = "Lake"
}

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

    -- 2. Security: Distance Validation
    local character = player.Character
    local rootPart = character and character.PrimaryPart

    if not rootPart then
        return -- Cannot gather if dead or spawning
    end

    local nodePos
    if resourceNode:IsA("BasePart") then
        nodePos = resourceNode.Position
    elseif resourceNode:IsA("Model") then
        nodePos = resourceNode:GetPivot().Position
    else
        return -- Invalid resource node type
    end

    if (rootPart.Position - nodePos).Magnitude > MAX_GATHER_DISTANCE then
        warn(string.format("[ResourceManager] Suspicious gather: %s is too far (%.1f studs)", player.Name, (rootPart.Position - nodePos).Magnitude))
        return
    end

    -- Determine what they got
    local nodeName = resourceNode.Name
    -- Map specific node names to generic Resource IDs (e.g., "OakTree" -> "Tree")
    local resourceId = NODE_TYPE_MAPPING[nodeName] or nodeName

    local drop = GameConfig.Resources[resourceId]

    if not drop then
        warn(string.format("[ResourceManager] Unknown resource type: %s (Mapped from: %s)", resourceId, nodeName))
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
    
    -- Verify Inventory Cap
    local data = PlayerDataHandler.Get(player)
    if data then
        local alreadyHasItem = false
        for _, slot in ipairs(data.Inventory) do
            if slot.ItemId == itemAwarded then
                alreadyHasItem = true
                break
            end
        end

        if not alreadyHasItem and #data.Inventory >= GameConfig.INVENTORY_CAPACITY then
            warn(string.format("[ResourceManager] %s Inventory Full. Cannot add %s", player.Name, itemAwarded))
            return
        end
    end
    
    -- Add Item
    local success = PlayerDataHandler.AddItem(player, itemAwarded, qty)
    
    if success then
        print(string.format("[ResourceManager] Awarded %s x%d to %s", itemAwarded, qty, player.Name))
        -- Notify client of successful gathering
        GatherEvent:FireClient(player, itemAwarded, qty)
    end
end

return ResourceManager
