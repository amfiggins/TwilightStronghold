--[[
    BuildingSystem.lua
    Handles server-side validation and placement of structures (Walls, Towers).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local BuildingSystem = {}

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceStructureEvent = Instance.new("RemoteEvent", Remotes)
PlaceStructureEvent.Name = "PlaceStructure"

-- Config (Mock Cost Table)
local STRUCTURE_COSTS = {
    ["Wall"] = { Resource = "wood_log", Amount = 5 },
    ["Tower"] = { Resource = "wood_log", Amount = 20 }
}

function BuildingSystem.Init()
    print("[BuildingSystem] Initialized.")
    
    PlaceStructureEvent.OnServerEvent:Connect(function(player, structureType, cframe)
        BuildingSystem.PlaceStructure(player, structureType, cframe)
    end)
end

function BuildingSystem.PlaceStructure(player, structureType, cframe)
    -- 1. Validate Cost
    local cost = STRUCTURE_COSTS[structureType]
    if not cost then return end
    
    -- Check Inventory (Simplified Logic using PlayerDataHandler)
    -- In a real scenario, we'd add a "RemoveItem" API to PlayerDataHandler
    -- local hasResources = PlayerDataHandler.HasItem(player, cost.Resource, cost.Amount)
    -- if not hasResources then return end
    
    -- 2. Validate Placement (Anti-Cheat)
    -- Ensure player is close to `cframe.Position`
    -- Ensure no collision
    
    -- 3. Place It
    print(string.format("[BuildingSystem] %s placed a %s", player.Name, structureType))
    
    local structure = Instance.new("Part")
    structure.Name = structureType
    structure.Size = Vector3.new(4, 8, 1) -- Wall dimensions
    structure.Anchored = true
    structure.CFrame = cframe
    structure.BrickColor = BrickColor.new("Brown")
    structure.Parent = workspace
    
    -- Deduct Cost (Mock)
    -- PlayerDataHandler.RemoveItem(player, cost.Resource, cost.Amount)
end

return BuildingSystem
