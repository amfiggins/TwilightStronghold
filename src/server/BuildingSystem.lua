--[[
    BuildingSystem.lua
    Server-side validation and placement of structures (Walls, Towers).
    Persists every successful placement via StructurePersistence.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local StructurePersistence = require(script.Parent.StructurePersistence)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BuildingSystem = {}

local BUILD_COOLDOWN = 0.5
local lastBuildTimes = {}

-- Tag every player-built structure so future systems (raid AI, persistence
-- restore, cleanup) can find them with workspace:GetDescendants() filtering.
local STRUCTURE_TAG = "TwilightStronghold_PlayerStructure"

-- Folder under workspace to keep things tidy.
local function getStructuresFolder()
    local existing = workspace:FindFirstChild("PlayerStructures")
    if existing then
        return existing
    end
    local folder = Instance.new("Folder")
    folder.Name = "PlayerStructures"
    folder.Parent = workspace
    return folder
end

-- Helper: Validate CFrame for NaNs and Inf
-- Optimization: Unpack components directly to avoid table allocation
local function isValidCFrame(cf)
    if typeof(cf) ~= "CFrame" then
        return false
    end

    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    if x ~= x or math.abs(x) == math.huge then
        return false
    end
    if y ~= y or math.abs(y) == math.huge then
        return false
    end
    if z ~= z or math.abs(z) == math.huge then
        return false
    end
    if r00 ~= r00 or math.abs(r00) == math.huge then
        return false
    end
    if r01 ~= r01 or math.abs(r01) == math.huge then
        return false
    end
    if r02 ~= r02 or math.abs(r02) == math.huge then
        return false
    end
    if r10 ~= r10 or math.abs(r10) == math.huge then
        return false
    end
    if r11 ~= r11 or math.abs(r11) == math.huge then
        return false
    end
    if r12 ~= r12 or math.abs(r12) == math.huge then
        return false
    end
    if r20 ~= r20 or math.abs(r20) == math.huge then
        return false
    end
    if r21 ~= r21 or math.abs(r21) == math.huge then
        return false
    end
    if r22 ~= r22 or math.abs(r22) == math.huge then
        return false
    end
    return true
end

-- Helper: detect collisions with existing parts at the proposed CFrame.
-- Uses GetPartBoundsInBox so terrain (which isn't a BasePart) is excluded —
-- that's intentional, terrain shouldn't block structure placement.
-- Returns true if the box intersects any non-terrain part except the player's
-- own character (so a wall can be placed at your feet).
-- (BUG-13 fix.)
local function hasCollision(cframe, size, ignoreCharacter)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    if ignoreCharacter then
        overlapParams.FilterDescendantsInstances = { ignoreCharacter }
    end
    -- Inset slightly so two flush-placed walls don't collide on edges.
    local insetSize = Vector3.new(math.max(0.1, size.X - 0.2), math.max(0.1, size.Y - 0.2), math.max(0.1, size.Z - 0.2))
    local hits = workspace:GetPartBoundsInBox(cframe, insetSize, overlapParams)
    return #hits > 0
end

-- Renderer: build the actual world Part for a given structure type at a CFrame.
-- Used for both fresh placements (PlaceStructure) and persistence restores
-- (called via StructurePersistence.SetRenderer).
local function renderStructure(record)
    local props = GameConfig.StructureProperties[record.structureType]
    if not props then
        warn(string.format("[BuildingSystem] Missing properties for %s", tostring(record.structureType)))
        return nil
    end

    local structure = Instance.new("Part")
    structure.Name = record.structureType
    structure.Size = props.Size
    structure.Anchored = props.Anchored
    structure.CFrame = record.cframe
    structure.Color = props.Color
    structure:AddTag(STRUCTURE_TAG)
    if record.ownerUserId then
        structure:SetAttribute("OwnerUserId", record.ownerUserId)
    end
    structure.Parent = getStructuresFolder()
    return structure
end

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceStructureEvent = Instance.new("RemoteEvent")
PlaceStructureEvent.Parent = Remotes
PlaceStructureEvent.Name = "PlaceStructure"

function BuildingSystem.Init()
    print("[BuildingSystem] Initialized.")

    -- Wire up persistence rendering and load any saved structures.
    StructurePersistence.SetRenderer(renderStructure)
    StructurePersistence.Init()

    PlaceStructureEvent.OnServerEvent:Connect(function(player, structureType, cframe)
        BuildingSystem.PlaceStructure(player, structureType, cframe)
    end)

    Players.PlayerRemoving:Connect(function(player)
        lastBuildTimes[player.UserId] = nil
    end)
end

function BuildingSystem.PlaceStructure(player, structureType, cframe)
    -- 0. Security: Rate Limiting
    local now = os.clock()
    local lastBuild = lastBuildTimes[player.UserId] or 0

    if (now - lastBuild) < BUILD_COOLDOWN then
        -- Silently fail to prevent log-flooding DoS vulnerabilities
        return false, "RateLimited"
    end
    lastBuildTimes[player.UserId] = now

    -- 1. Validate Cost Existence
    local cost = GameConfig.StructureCosts[structureType]
    if not cost then
        return false, "InvalidStructure"
    end

    local props = GameConfig.StructureProperties[structureType]
    if not props then
        warn(string.format("[BuildingSystem] Missing properties for %s", structureType))
        return false, "MissingProperties"
    end

    -- 2. Validate Placement (Anti-Cheat)
    -- Ensure cframe is valid (Type Check & Finite numbers only - DoS Prevention)
    if not isValidCFrame(cframe) then
        warn(string.format("[BuildingSystem] Invalid or Malformed CFrame (NaN/Inf) received from %s", player.Name))
        return false, "InvalidCFrame"
    end

    -- Ensure player is close to `cframe.Position`
    local character = player.Character
    local rootPart = character and character.PrimaryPart

    if not rootPart then
        return false, "PlayerDead" -- Cannot build if dead or spawning
    end

    local dx = rootPart.Position.X - cframe.Position.X
    local dy = rootPart.Position.Y - cframe.Position.Y
    local dz = rootPart.Position.Z - cframe.Position.Z
    local distSq = dx * dx + dy * dy + dz * dz
    if not (distSq <= GameConfig.MAX_BUILD_DISTANCE * GameConfig.MAX_BUILD_DISTANCE) then
        warn(string.format("[BuildingSystem] Suspicious build: %s is too far or provided NaN position", player.Name))
        return false, "TooFar"
    end

    -- 2b. Collision check (BUG-13). Reject placement if the proposed bounds
    -- intersect any non-terrain part. We allow the player's own character
    -- to overlap so you can wall yourself in.
    if hasCollision(cframe, props.Size, character) then
        return false, "Collides"
    end

    -- 3. Deduct Cost
    local success = PlayerDataHandler.RemoveItem(player, cost.Resource, cost.Amount)
    if not success then
        warn(
            string.format("[BuildingSystem] %s failed to build %s: Insufficient resources.", player.Name, structureType)
        )
        return false, "InsufficientResources"
    end

    -- 4. Render and persist
    local instance = renderStructure({
        structureType = structureType,
        cframe = cframe,
        ownerUserId = player.UserId,
    })
    if not instance then
        return false, "RenderFailed"
    end

    StructurePersistence.AddStructure(structureType, cframe, player.UserId)

    print(string.format("[BuildingSystem] %s placed a %s", player.Name, structureType))
    return true, "Success"
end

return BuildingSystem
