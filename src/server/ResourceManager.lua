--[[
    ResourceManager.lua
    Handles server-side validation of resource gathering and awards items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ResourceManager = {}

local MAX_GATHER_DISTANCE = 25 -- Maximum distance in studs to allow gathering
local GATHER_COOLDOWN = 1.0 -- Seconds between gathers

local lastGatherTimes = {} -- [UserId] = timestamp

-- Create Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
    RemotesFolder = Instance.new("Folder")
    RemotesFolder.Name = "Remotes"
    RemotesFolder.Parent = ReplicatedStorage
end

local GatherEvent = RemotesFolder:FindFirstChild("GatherResource")
if not GatherEvent then
    GatherEvent = Instance.new("RemoteEvent")
    GatherEvent.Name = "GatherResource"
    GatherEvent.Parent = RemotesFolder
end

function ResourceManager.Init()
    GatherEvent.OnServerEvent:Connect(ResourceManager.OnGatherRequest)

    Players.PlayerRemoving:Connect(function(player)
        lastGatherTimes[player.UserId] = nil
    end)

    print("[ResourceManager] Initialized. Listening for Gather events.")
end

function ResourceManager.OnGatherRequest(player, resourceNode)
    -- 0. Security: Rate Limiting
    local now = os.clock()
    local lastGather = lastGatherTimes[player.UserId] or 0

    if (now - lastGather) < GATHER_COOLDOWN then
        -- Silently fail or warn if excessive
        return
    end
    lastGatherTimes[player.UserId] = now

    -- 1. Validation Logic
    if typeof(resourceNode) ~= "Instance" or not resourceNode:IsDescendantOf(workspace) then
        warn("[ResourceManager] Invalid resource node received.")
        return
    end

    if not resourceNode:IsDescendantOf(game.Workspace) then
        return -- Ignore requests for deleted/inactive nodes
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

    -- ⚡ Bolt: Fast squared distance calculation to avoid math.sqrt
    local delta = rootPart.Position - nodePos
    local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
    if not (distSq <= MAX_GATHER_DISTANCE * MAX_GATHER_DISTANCE) then
        warn(string.format("[ResourceManager] Suspicious gather: %s is too far or provided NaN position", player.Name))
        return
    end

    -- 3. Security: Interaction Validation
    -- Ensure the object has an active ProximityPrompt intended for gathering.
    -- This prevents exploiters from gathering arbitrary parts in the workspace (e.g. decorative props).
    local prompt = resourceNode:FindFirstChild("Gather")
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then
        warn(
            string.format(
                "[ResourceManager] Invalid gather request from %s: Node has no active 'Gather' prompt.",
                player.Name
            )
        )
        return
    end

    -- Determine what they got
    local nodeName = resourceNode.Name

    -- Map specific node names (from the workspace) to generic Resource IDs (from GameConfig)
    -- e.g., "OakTree" -> "Tree", "Boulder" -> "Rock"
    -- This allows multiple visual variations to yield the same resource type.
    local resourceId = GameConfig.NodeTypeMapping[nodeName] or nodeName

    local drop = GameConfig.Resources[resourceId]

    if not drop then
        warn(string.format("[ResourceManager] Unknown resource type: %s (Mapped from: %s)", resourceId, nodeName))
        return
    end

    -- Logic: Roll for Rarity (The "Fisch" mechanic)
    local roll = math.random(1, 100)
    local itemAwarded = drop.Item
    local qty = math.random(drop.Min, drop.Max)

    -- Generic Rare Drop Logic
    if drop.RareItem and drop.RareChance and roll > (100 - drop.RareChance) then
        itemAwarded = drop.RareItem
    end

    -- Add Item
    local success, reason = PlayerDataHandler.AddItem(player, itemAwarded, qty)

    if success then
        print(string.format("[ResourceManager] Awarded %s x%d to %s", itemAwarded, qty, player.Name))

        -- Deplete Resource
        if drop.DestroyOnGather then
            resourceNode:Destroy()
        end

        -- Notify client of successful gathering
        if GatherEvent then
            GatherEvent:FireClient(player, itemAwarded, qty)
        end
    elseif reason == "InventoryFull" then
        warn(string.format("[ResourceManager] %s Inventory Full. Cannot add %s", player.Name, itemAwarded))
    end
end

return ResourceManager
