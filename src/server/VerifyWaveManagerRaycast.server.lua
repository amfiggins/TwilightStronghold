--[[
    VerifyWaveManagerRaycast.server.lua

    Verification script for Bolt's Raycast optimization in WaveManager.

    Since 'workspace.Raycast' cannot be easily hooked in a standard Roblox runtime without a
    dedicated test framework (like Rostest/TestEZ) that mocks the environment,
    this script serves as a sanity check and provides instructions for manual verification.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WaveManager = require(script.Parent.WaveManager)

print("---------------------------------------------------------")
print("⚡ Bolt Verification: WaveManager Raycast Optimization")
print("---------------------------------------------------------")

-- 1. Verify Module Load
print("1. Loading WaveManager...")
if WaveManager and type(WaveManager.Init) == "function" then
    print("✅ WaveManager loaded successfully.")

    -- Initialize to check for runtime errors in Init (e.g. syntax errors)
    local success, err = pcall(function()
        WaveManager.Init()
    end)

    if success then
        print("✅ WaveManager.Init() executed without errors.")
    else
        warn("❌ WaveManager.Init() failed: " .. tostring(err))
    end
else
    warn("❌ Failed to load WaveManager.")
end

-- 2. Verification Instructions
print("\n2. Verification Instructions:")
print("   To confirm the Raycast optimization is active:")
print("   A. Open 'src/server/WaveManager.lua' and locate the 'AI Loop'.")
print("   B. Confirm 'workspace:Raycast' is called when distance < 30.")
print("   C. Run the game in Studio.")
print("   D. Allow an enemy to spawn near you (< 30 studs).")
print("   E. The enemy should move directly to you without delay, bypassing pathfinding.")
print("   F. (Optional) Add 'print(\"Raycast Hit!\")' inside the raycast success block to confirm triggers.")

print("---------------------------------------------------------")
print("Optimization Logic Summary:")
print("- Added 'DEATH_TWEEN_INFO' constant to reduce object creation.")
print("- Added 'RaycastParams' caching per enemy.")
print("- Added Line-of-Sight (Raycast) check to skip 'ComputeAsync'.")
print("---------------------------------------------------------")
