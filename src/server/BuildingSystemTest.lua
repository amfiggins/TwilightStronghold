--[[
    BuildingSystemTest.lua
    Test script for verifying BuildingSystem refactoring.

    Usage:
    This script is intended to be run in a Roblox Studio environment or a test runner that supports Roblox API.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Mock Dependencies if running in isolation, otherwise assume they exist
-- Note: Paths might need adjustment depending on the actual runtime environment structure.
-- This assumes standard Rojo structure where `src/server` maps to `ServerScriptService.Server`
-- and `src/shared` maps to `ReplicatedStorage.Shared`.

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
-- Since we are in the same folder structure in the repo, we can simulate requires if needed,
-- but for actual Roblox execution, we use the services.

local function TestBuildingSystem()
    print("Running BuildingSystem Tests...")

    -- Locate Modules
    local BuildingSystem = require(game:GetService("ServerScriptService").Server.BuildingSystem)
    local PlayerDataHandler = require(game:GetService("ServerScriptService").Server.PlayerDataHandler)

    -- Mock Player
    local mockPlayer = Instance.new("Player")
    mockPlayer.Name = "TestPlayer"
    mockPlayer.UserId = 12345

    -- Mock Character
    local character = Instance.new("Model")
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Position = Vector3.new(0, 5, 0)
    rootPart.Parent = character
    character.PrimaryPart = rootPart
    mockPlayer.Character = character

    -- 1. Test Config Values
    assert(GameConfig.MAX_BUILD_DISTANCE == 20, "MAX_BUILD_DISTANCE should be 20")
    assert(GameConfig.StructureProperties["Wall"], "StructureProperties should have 'Wall'")
    assert(GameConfig.StructureProperties["Tower"], "StructureProperties should have 'Tower'")
    assert(GameConfig.StructureProperties["Wall"].Size == Vector3.new(4, 8, 1), "Wall size mismatch")

    -- 2. Test PlaceStructure Logic (Mocking PlayerDataHandler.RemoveItem)
    -- We need to mock RemoveItem to return true since we don't have a real data store session
    local originalRemoveItem = PlayerDataHandler.RemoveItem
    PlayerDataHandler.RemoveItem = function(p, item, amount)
        print(string.format("Mock RemoveItem called: %s, %s, %d", p.Name, item, amount))
        return true
    end

    local targetCFrame = CFrame.new(0, 5, 10) -- 10 studs away (within 20)

    -- Clean workspace before test
    local existing = workspace:FindFirstChild("Wall")
    if existing then existing:Destroy() end

    BuildingSystem.PlaceStructure(mockPlayer, "Wall", targetCFrame)

    -- Verify placement
    local placedPart = workspace:FindFirstChild("Wall")
    assert(placedPart, "Wall should be placed in workspace")
    assert(placedPart.Size == GameConfig.StructureProperties["Wall"].Size, "Placed Wall size mismatch")
    assert(placedPart.Color == GameConfig.StructureProperties["Wall"].Color, "Placed Wall Color mismatch")
    assert(placedPart.Anchored == GameConfig.StructureProperties["Wall"].Anchored, "Placed Wall Anchored mismatch")

    print("BuildingSystem Tests Passed!")

    -- Cleanup
    PlayerDataHandler.RemoveItem = originalRemoveItem
    if placedPart then placedPart:Destroy() end
    mockPlayer:Destroy()
    character:Destroy()
end

return TestBuildingSystem
