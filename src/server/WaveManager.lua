--[[
    WaveManager.lua
    Handles spawning enemies during the Night Phase.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local WaveManager = {}

-- Config
local SPAWN_RATE = 5 -- Spawn an enemy every X seconds

local activePlayers = {}
Players.PlayerAdded:Connect(function(player)
    table.insert(activePlayers, player)
end)
Players.PlayerRemoving:Connect(function(player)
    local idx = table.find(activePlayers, player)
    if idx then
        table.remove(activePlayers, idx)
    end
end)

-- Initialize activePlayers for players already in the game when script runs
for _, player in ipairs(Players:GetPlayers()) do
    table.insert(activePlayers, player)
end


-- Optimization: Cache template to avoid repeated Instance.new and property setting
local enemyTemplate -- Template part for enemies
function WaveManager.Init()
    print("[WaveManager] Initializing...")

    -- Create the template model once
    enemyTemplate = Instance.new("Model")
    enemyTemplate.Name = "Enemy"

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.BrickColor = BrickColor.new("Really red")
    rootPart.Anchored = false -- Unanchored to allow movement
    rootPart.CanCollide = true
    rootPart.Parent = enemyTemplate

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    humanoid.Parent = enemyTemplate

    enemyTemplate.PrimaryPart = rootPart

    print("[WaveManager] Initialized with death logic and pathfinding template.")
end

local function findNearestPlayer(position)
    local nearestPlayer = nil
    local minDistanceSq = math.huge

    for _, player in ipairs(activePlayers) do
        local character = player.Character
        if character and character.PrimaryPart then
            -- ⚡ Bolt: Fast squared distance calculation
            local delta = character.PrimaryPart.Position - position
            local distanceSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
            if distanceSq < minDistanceSq then
                minDistanceSq = distanceSq
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
    if not enemyTemplate then
        warn("[WaveManager] Not initialized")
        return
    end

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

    -- Set start position
    local startPos = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
    enemy:SetPrimaryPartCFrame(CFrame.new(startPos))

    enemy.Parent = workspace
    
    -- AI Loop (Pathfinding)
    task.spawn(function()
        -- Optimization: Reuse Path object to avoid allocation in loop
        local path = PathfindingService:CreatePath()

        -- Reuse RaycastParams to avoid allocation in loop
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {enemy}

        while enemy.Parent and humanoid and humanoid.Health > 0 do
            local targetPlayer = findNearestPlayer(rootPart.Position)
            local updateRate = 0.5

            if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
                local targetPos = targetPlayer.Character.PrimaryPart.Position
                -- ⚡ Bolt: Fast squared distance calculation to avoid math.sqrt
                local delta = targetPos - rootPart.Position
                local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z

                -- Optimization: Throttle updates based on distance
                if distSq > 10000 then -- 100^2
                    updateRate = 2.0
                elseif distSq > 2500 then -- 50^2
                    updateRate = 1.0
                end

                local usePathfinding = true

                -- Optimization: Use direct movement if close and clear Line of Sight
                if distSq < 900 then -- 30^2
                    -- Update filter to include target character (so we don't hit it)
                    rayParams.FilterDescendantsInstances = {enemy, targetPlayer.Character}

                    local direction = targetPos - rootPart.Position
                    local result = workspace:Raycast(rootPart.Position, direction, rayParams)

                    if not result then
                        usePathfinding = false
                    end
                end

                if usePathfinding then
                    -- Compute path (Reuses the 'path' object)
                    local success, errorMessage = pcall(path.ComputeAsync, path, rootPart.Position, targetPos)

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
                else
                    -- Direct movement optimization
                    humanoid:MoveTo(targetPos)
                end
            end

            -- Update path at variable rate
            task.wait(updateRate)
        end
    end)

end

return WaveManager
