--[[
    BuildingSystem.lua
    Handles server-side validation and placement of structures (Walls, Towers).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BuildingSystem = {}

local BUILD_COOLDOWN = 0.5
local lastBuildTimes = {}

-- Helper: Validate CFrame for NaNs and Inf
local function isValidCFrame(cf)
    if typeof(cf) ~= "CFrame" then return false end

    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()

    if x ~= x or math.abs(x) == math.huge then return false end
    if y ~= y or math.abs(y) == math.huge then return false end
    if z ~= z or math.abs(z) == math.huge then return false end
    if r00 ~= r00 or math.abs(r00) == math.huge then return false end
    if r01 ~= r01 or math.abs(r01) == math.huge then return false end
    if r02 ~= r02 or math.abs(r02) == math.huge then return false end
    if r10 ~= r10 or math.abs(r10) == math.huge then return false end
    if r11 ~= r11 or math.abs(r11) == math.huge then return false end
    if r12 ~= r12 or math.abs(r12) == math.huge then return false end
    if r20 ~= r20 or math.abs(r20) == math.huge then return false end
    if r21 ~= r21 or math.abs(r21) == math.huge then return false end
    if r22 ~= r22 or math.abs(r22) == math.huge then return false end

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
    if not cost then return false, "InvalidStructure" end
    
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

    local dist = (rootPart.Position - cframe.Position).Magnitude
    if dist > GameConfig.MAX_BUILD_DISTANCE then
        warn(string.format("[BuildingSystem] Suspicious build: %s is too far (%.1f studs)", player.Name, dist))
        return false, "TooFar"
    end



    -- Ensure no collision

    -- 3. Deduct Cost
    local success = PlayerDataHandler.RemoveItem(player, cost.Resource, cost.Amount)
    if not success then
        warn(string.format("[BuildingSystem] %s failed to build %s: Insufficient resources.", player.Name, structureType))
        return false, "InsufficientResources"
    end
    
    -- 4. Place It
    print(string.format("[BuildingSystem] %s placed a %s", player.Name, structureType))
    
    local props = GameConfig.StructureProperties[structureType]
    if not props then
        warn(string.format("[BuildingSystem] Missing properties for %s", structureType))
        return false, "MissingProperties"
    end

    local structure = Instance.new("Part")
    structure.Name = structureType
    structure.Size = props.Size
    structure.Anchored = props.Anchored
    structure.CFrame = cframe
    structure.Color = props.Color
    structure.Parent = workspace

    return true, "Success"
end

return BuildingSystem
