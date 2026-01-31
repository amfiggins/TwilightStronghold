--[[
    VerifyWaveManager.server.lua
    Verifies that WaveManager loads and initializes correctly.
    Run this in Roblox Studio to verify.
]]

local WaveManager = require(script.Parent.WaveManager)

print("Verifying WaveManager...")

if type(WaveManager) ~= "table" then
    error("WaveManager did not return a table")
end

if type(WaveManager.Init) ~= "function" then
    error("WaveManager.Init is missing")
end

if type(WaveManager.SpawnEnemy) ~= "function" then
    error("WaveManager.SpawnEnemy is missing")
end

-- Test Initialization
local success, err = pcall(function()
    WaveManager.Init()
end)

if not success then
    error("WaveManager.Init failed: " .. tostring(err))
end

print("WaveManager verification passed.")
