--[[
    WaveManager.lua
    Handles spawning enemies during the Night Phase.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WaveManager = {}

-- Config
local SPAWN_RATE = 5 -- Spawn an enemy every X seconds

-- Optimization: Cache template to avoid repeated Instance.new and property setting
local enemyTemplate -- Template part for enemies

function WaveManager.Init()
    print("[WaveManager] Initializing...")

    -- Initialize the enemy template for cloning
    local template = Instance.new("Part")
    template.Name = "Enemy"
    template.BrickColor = BrickColor.new("Really red")
    template.Anchored = false

    enemyTemplate = template

    print("[WaveManager] Initialized.")
end

function WaveManager.StartWave(waveNumber)
    print(string.format("[WaveManager] Starting Wave %d...", waveNumber))
    
    task.spawn(function()
        local DayNightCycle = require(script.Parent.DayNightCycle)
        
        while DayNightCycle.Phase == "Night" do
            task.wait(SPAWN_RATE)
            if DayNightCycle.Phase ~= "Night" then break end
            
            WaveManager.SpawnEnemy(waveNumber)
        end
        
        print("[WaveManager] Wave Ended.")
    end)
end

function WaveManager.SpawnEnemy(difficulty)
    if not enemyTemplate then
        warn("WaveManager not initialized")
        return
    end

    -- Mock Enemy Spawing
    -- In real impl, we'd clone a rig from ServerStorage and use PathfindingService
    
    print(string.format("[WaveManager] Spawning Enemy (Lvl %d)", difficulty))
    
    -- Visual Debug (Create a part)
    -- Optimization: Clone from template instead of creating new
    local part = enemyTemplate:Clone()

    -- Set position (Physics already enabled in template)
    part.Position = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
    part.Parent = workspace
    
    -- Clean up after a few seconds mock death
    task.delay(10, function()
        if part then part:Destroy() end
    end)
end

return WaveManager
