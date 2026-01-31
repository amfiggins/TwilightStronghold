--[[
    WaveManager.lua
    Handles spawning enemies during the Night Phase.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local WaveManager = {}

-- Config
local SPAWN_RATE = 5 -- Spawn an enemy every X seconds

-- Optimization: Cache template to avoid repeated Instance.new and property setting
local enemyTemplate

function WaveManager.Init()
    print("[WaveManager] Initialized.")

    -- Create the template model once
    enemyTemplate = Instance.new("Model")
    enemyTemplate.Name = "Enemy"

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(4, 4, 4)
    rootPart.BrickColor = BrickColor.new("Really red")
    rootPart.Anchored = false -- Unanchored to allow movement
    rootPart.Parent = enemyTemplate

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    humanoid.Parent = enemyTemplate

    enemyTemplate.PrimaryPart = rootPart
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
    -- Mock Enemy Spawing
    -- In real impl, we'd clone a rig from ServerStorage and use PathfindingService
    
    print(string.format("[WaveManager] Spawning Enemy (Lvl %d)", difficulty))
    
    -- Optimization: Clone from template instead of creating new
    local enemy = enemyTemplate:Clone()
    local rootPart = enemy.PrimaryPart
    local humanoid = enemy:FindFirstChild("Humanoid")

    -- Set stats based on difficulty
    if humanoid then
        humanoid.MaxHealth = 100 + (difficulty * 10)
        humanoid.Health = humanoid.MaxHealth

        humanoid.Died:Connect(function()
            -- Death Sequence
            if rootPart then
                rootPart.Anchored = true -- Stop moving
                rootPart.CanCollide = false

                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {Transparency = 1})
                tween:Play()

                tween.Completed:Wait()
            end
            enemy:Destroy()
        end)
    end

    if rootPart then
        rootPart.CFrame = CFrame.new(math.random(-50, 50), 5, math.random(-50, 50))
    end
    enemy.Parent = workspace
end

return WaveManager
