--[[
    BuildingSystem.lua
    Handles server-side validation and placement of structures (Walls, Towers).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BuildingSystem = {}

local MAX_BUILD_DISTANCE = 20 -- Maximum distance in studs to allow building
local WALL_SIZE = Vector3.new(4, 8, 1) -- Standard structure size
local COLLISION_MARGIN = 0.1 -- Reduction margin to allow face-touching placement

-- Helper: Validate CFrame for NaNs and Inf
local function isValidCFrame(cf)
    if typeof(cf) ~= "CFrame" then return false end

    local components = {cf:GetComponents()}
    for _, v in ipairs(components) do
        -- Check for NaN (v ~= v) and Infinity
        if v ~= v or math.abs(v) == math.huge then
            return false
        end
    end
    return true
end

-- Helper: Check Collision (OverlapParams)
local function checkCollision(cframe, size)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {} -- Consider everything collidable by default

    -- Reduce size slightly to allow "flush" placement (e.g. on ground or stacking)
    local checkSize = size - Vector3.new(COLLISION_MARGIN, COLLISION_MARGIN, COLLISION_MARGIN)

    local parts = workspace:GetPartBoundsInBox(cframe, checkSize, overlapParams)
    return #parts > 0
end

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceStructureEvent = Instance.new("RemoteEvent", Remotes)
PlaceStructureEvent.Name = "PlaceStructure"

function BuildingSystem.Init()
    print("[BuildingSystem] Initialized.")
    
    PlaceStructureEvent.OnServerEvent:Connect(function(player, structureType, cframe)
        BuildingSystem.PlaceStructure(player, structureType, cframe)
    end)
end

function BuildingSystem.PlaceStructure(player, structureType, cframe)
    -- 1. Validate Cost Existence
    local cost = GameConfig.StructureCosts[structureType]
    if not cost then return end
    
    -- 2. Validate Placement (Anti-Cheat)
    -- Ensure cframe is valid (Type Check & Finite numbers only - DoS Prevention)
    if not isValidCFrame(cframe) then
        warn(string.format("[BuildingSystem] Invalid or Malformed CFrame (NaN/Inf) received from %s", player.Name))
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

    -- Ensure no collision (Server-Side Validation)
    if checkCollision(cframe, WALL_SIZE) then
        warn(string.format("[BuildingSystem] Build failed: %s attempted to build intersecting geometry.", player.Name))
        return
    end

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
    structure.Size = WALL_SIZE
    structure.Anchored = true
    structure.CFrame = cframe
    structure.BrickColor = BrickColor.new("Brown")
    structure.Parent = workspace

end

return BuildingSystem
