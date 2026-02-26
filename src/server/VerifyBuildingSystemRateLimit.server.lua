--[[
    VerifyBuildingSystemRateLimit.server.lua
    Verifies that the BuildingSystem correctly enforces rate limits on structure placement.
    Intended to be run in Roblox Studio or a test environment.
]]

local BuildingSystem = require(script.Parent.BuildingSystem)

print("Verifying BuildingSystem Rate Limiting...")

-- Mock Player
local mockPlayer = {
    Name = "TestPlayer",
    UserId = 12345,
    Character = Instance.new("Model")
}
local rootPart = Instance.new("Part")
rootPart.Name = "HumanoidRootPart"
rootPart.Position = Vector3.new(0, 5, 0)
rootPart.Parent = mockPlayer.Character
mockPlayer.Character.PrimaryPart = rootPart

-- Mock CFrame (Valid)
local testCFrame = CFrame.new(0, 0, 0)

-- Helper: Interpret Result
local function checkResult(success, reason, expectedReason)
    if success then
        return "Success"
    else
        return "Fail: " .. tostring(reason)
    end
end

-- Test 1: First Build (Should NOT be rate limited)
-- Note: It might fail due to resources, but it should NOT fail due to RateLimit.
print("Test 1: First Build Attempt")
local success1, reason1 = BuildingSystem.PlaceStructure(mockPlayer, "Wall", testCFrame)

if success1 then
    print("Test 1 Passed: Build succeeded.")
elseif reason1 == "RateLimited" then
    warn("Test 1 FAILED: Unexpected Rate Limit on first call!")
else
    print("Test 1 Passed: Build processed (failed due to " .. tostring(reason1) .. ", which is expected for mock).")
end

-- Test 2: Rapid Second Build (Should BE rate limited)
print("Test 2: Rapid Second Build Attempt")
local success2, reason2 = BuildingSystem.PlaceStructure(mockPlayer, "Wall", testCFrame)

if not success2 and reason2 == "RateLimited" then
    print("Test 2 Passed: Second build blocked by Rate Limit.")
else
    warn("Test 2 FAILED: Expected Rate Limit failure, got: " .. checkResult(success2, reason2))
end

-- Test 3: Wait and Build (Should NOT be rate limited)
print("Test 3: Build after Cooldown")
task.wait(0.6) -- Wait > 0.5s
local success3, reason3 = BuildingSystem.PlaceStructure(mockPlayer, "Wall", testCFrame)

if success3 then
    print("Test 3 Passed: Build succeeded.")
elseif reason3 == "RateLimited" then
    warn("Test 3 FAILED: Rate Limit persisted after cooldown!")
else
    print("Test 3 Passed: Build processed (failed due to " .. tostring(reason3) .. ", which is expected for mock).")
end

print("BuildingSystem Rate Limit Verification Complete.")
