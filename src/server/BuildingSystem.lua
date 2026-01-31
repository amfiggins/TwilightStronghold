--[[
    BuildingSystem.lua
    Handles server-side validation and placement of structures (Walls, Towers).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local BuildingSystem = {}

local MAX_BUILD_DISTANCE = 20 -- Maximum distance in studs to allow building

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
    -- 1. Validate Cost Existence
    local cost = STRUCTURE_COSTS[structureType]
    if not cost then return end
    
    -- 2. Validate Placement (Anti-Cheat)
    -- Ensure cframe is valid
    if typeof(cframe) ~= "CFrame" then
        warn(string.format("[BuildingSystem] Invalid CFrame received from %s", player.Name))
        return
    end

    -- Ensure player is close to `cframe.Position`
    local character = player.Character
    local rootPart = character and character.PrimaryPart

    if not rootPart then
        return -- Cannot build if dead or spawning
    end

    local dist = (rootPart.Position - cframe.Position).Magnitude
    if dist > MAX_BUILD_DISTANCE then
        warn(string.format("[BuildingSystem] Suspicious build: %s is too far (%.1f studs)", player.Name, dist))
        return
    end

    -- Ensure no collision

    -- 3. Deduct Cost
    local success = PlayerDataHandler.RemoveItem(player, cost.Resource, cost.Amount)
    if not success then
        warn(string.format("[BuildingSystem] %s failed to build %s: Insufficient resources.", player.Name, structureType))
        return
    end
    
    -- 4. Place It
    print(string.format("[BuildingSystem] %s placed a %s", player.Name, structureType))
    
    local structure = Instance.new("Part")
    structure.Name = structureType
    structure.Size = Vector3.new(4, 8, 1) -- Wall dimensions
    structure.Anchored = true
    structure.CFrame = cframe
    structure.BrickColor = BrickColor.new("Brown")
    structure.Parent = workspace
end

return BuildingSystem
