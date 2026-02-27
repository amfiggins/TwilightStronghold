--[[
    VerifyBuildingSystemRateLimit.server.lua
    Manual verification for BuildingSystem rate limiting.
    Run this script in Studio to test.
]]

local BuildingSystem = require(script.Parent.BuildingSystem)
local Players = game:GetService("Players")

print("Verifying BuildingSystem Rate Limiting...")

-- Mock Player
local mockPlayer = {
    Name = "SentinelTester",
    UserId = 12345678,
    Character = {
        PrimaryPart = {
            Position = Vector3.new(0, 5, 0)
        }
    }
}

-- Mock CFrame
local validCFrame = CFrame.new(Vector3.new(5, 5, 5))

-- 1. First Call (Should Succeed)
print("Attempt 1: Build (Should Succeed)")
BuildingSystem.PlaceStructure(mockPlayer, "Wall", validCFrame)

-- 2. Immediate Second Call (Should be Rate Limited)
print("Attempt 2: Build Immediately (Should be Rate Limited / Ignored)")
BuildingSystem.PlaceStructure(mockPlayer, "Wall", validCFrame)

-- 3. Wait for Cooldown
task.wait(1.0)

-- 4. Third Call (Should Succeed)
print("Attempt 3: Build after Wait (Should Succeed)")
BuildingSystem.PlaceStructure(mockPlayer, "Wall", validCFrame)

print("BuildingSystem Rate Limit verification complete. Check output for 'Rate Limited' logs if implemented.")
