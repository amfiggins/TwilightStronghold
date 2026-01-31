--[[
    WaveManager.lua
    Handles spawning enemies during the Night Phase.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local WaveManager = {}

-- Config
local SPAWN_RATE = 5 -- Spawn an enemy every X seconds

-- Optimization: Cache template to avoid repeated Instance.new and property setting
local enemyTemplate

function WaveManager.Init()
    print("[WaveManager] Initialized.")

    -- Create the template Model once
    enemyTemplate = Instance.new("Model")
    enemyTemplate.Name = "Enemy"

    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2, 2, 1)
    hrp.BrickColor = BrickColor.new("Really red")
    hrp.Transparency = 0 -- Keep visible for debugging
    hrp.CanCollide = true
    hrp.Anchored = false
    hrp.Parent = enemyTemplate

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = enemyTemplate

    enemyTemplate.PrimaryPart = hrp
end

local function findNearestPlayer(position)
    local nearestPlayer = nil
    local minDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character.PrimaryPart then
            local distance = (character.PrimaryPart.Position - position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer
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
    print(string.format("[WaveManager] Spawning Enemy (Lvl %d)", difficulty))
    
    local enemy = enemyTemplate:Clone()
    local hrp = enemy.PrimaryPart
    local humanoid = enemy:FindFirstChild("Humanoid")

    -- Set start position
    local startPos = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
    enemy:SetPrimaryPartCFrame(CFrame.new(startPos))

    enemy.Parent = workspace
    
    -- AI Loop
    task.spawn(function()
        while enemy.Parent and humanoid.Health > 0 do
            local targetPlayer = findNearestPlayer(hrp.Position)

            if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
                local targetPos = targetPlayer.Character.PrimaryPart.Position

                -- Compute path
                local path = PathfindingService:CreatePath()
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(hrp.Position, targetPos)
                end)

                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()

                    -- Move to the second waypoint (the first one is the current position)
                    if #waypoints >= 2 then
                        humanoid:MoveTo(waypoints[2].Position)
                    else
                        -- Fallback: Move directly to target if very close
                        humanoid:MoveTo(targetPos)
                    end
                else
                    if not success then
                        warn("[WaveManager] Path computation failed:", errorMessage)
                    end
                    -- Fallback: Try moving directly to target
                    humanoid:MoveTo(targetPos)
                end
            end

            -- Update path every 0.5 seconds
            task.wait(0.5)
        end
    end)
end

return WaveManager
