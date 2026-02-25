--[[
    BuildingSystem.lua
    Handles server-side validation and placement of structures (Walls, Towers).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BuildingSystem = {}

local MAX_BUILD_DISTANCE = 20 -- Maximum distance in studs to allow building
local BUILD_COOLDOWN = 0.5 -- Seconds between builds to prevent spam
local COLLISION_MARGIN = 0.1 -- Small margin to prevent self-intersection
local WALL_SIZE = Vector3.new(4, 8, 1) -- Standard Wall Size

local lastBuildTimes = {} -- [UserId] = timestamp

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

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceStructureEvent = Instance.new("RemoteEvent", Remotes)
PlaceStructureEvent.Name = "PlaceStructure"

function BuildingSystem.Init()
    print("[BuildingSystem] Initialized.")
    
    PlaceStructureEvent.OnServerEvent:Connect(function(player, structureType, cframe)
        BuildingSystem.PlaceStructure(player, structureType, cframe)
    end)

    -- Clean up memory on player leave
    Players.PlayerRemoving:Connect(function(player)
        lastBuildTimes[player.UserId] = nil
    end)
end

function BuildingSystem.PlaceStructure(player, structureType, cframe)
    -- 0. Security: Rate Limiting (DoS Prevention)
    local userId = player.UserId
    local now = os.clock()
    local lastBuild = lastBuildTimes[userId] or 0

    if (now - lastBuild) < BUILD_COOLDOWN then
        -- Silently fail to discourage spam
        return
    end
    lastBuildTimes[userId] = now

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



    -- Security: Ensure no collision (Prevent Stacking/Clipping)
    -- Using a slightly smaller box to allow placing next to each other
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {character} -- Ignore self
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Check if box is clear (margin for flush placement)
    local parts = workspace:GetPartBoundsInBox(cframe, WALL_SIZE - Vector3.new(COLLISION_MARGIN, COLLISION_MARGIN, COLLISION_MARGIN), overlapParams)

    if #parts > 0 then
        -- Check if we are colliding with something substantial (not just effects)
        local collided = false
        for _, part in ipairs(parts) do
            if part.CanCollide then
                collided = true
                break
            end
        end

        if collided then
            warn(string.format("[BuildingSystem] Build failed: Collision detected for %s", player.Name))
            return
        end
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
    structure.Size = WALL_SIZE -- Use constant
    structure.Anchored = true
    structure.CFrame = cframe
    structure.BrickColor = BrickColor.new("Brown")
    structure.Parent = workspace

end

return BuildingSystem
