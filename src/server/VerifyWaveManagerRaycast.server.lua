--[[
    VerifyWaveManagerRaycast.server.lua
    Verifies that WaveManager spawns enemies and handles pathfinding logic correctly.
    Since we cannot mock workspace.Raycast directly in this environment without dependency injection,
    this script primarily ensures that the new logic doesn't throw runtime errors.
]]

local WaveManager = require(script.Parent.WaveManager)

print("Verifying WaveManager Raycast Logic...")

-- Initialize
local success, err = pcall(function()
    WaveManager.Init()
end)

if not success then
    error("WaveManager.Init failed: " .. tostring(err))
end

-- Spawn Enemy
success, err = pcall(function()
    WaveManager.SpawnEnemy(1)
end)

if not success then
    error("WaveManager.SpawnEnemy failed: " .. tostring(err))
end

print("WaveManager Raycast Logic Verified (No Crashes).")
