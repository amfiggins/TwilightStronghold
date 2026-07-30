--[[
    WaveManager.lua
    Spawns enemies during the Night Phase. Each spawn is registered with the
    CombatSystem (kill rewards), enemies deal touch damage to players, and
    every alive enemy is despawned when dawn breaks.
]]
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local WaveManager = {}

local CombatSystem -- lazy-required to avoid require cycle on init order

-- ── Config ────────────────────────────────────────────────────────────────
local SPAWN_RATE = 5 -- seconds between spawns during a wave
local PHASE_CHECK_INTERVAL = 0.5 -- granularity for phase-end detection (BUG-11)
local TOUCH_DAMAGE = 8 -- base damage per touch hit
local TOUCH_DAMAGE_PER_DIFFICULTY = 2
local TOUCH_DAMAGE_COOLDOWN_SECONDS = 1.0 -- per (enemy, player) pair

-- ── Active player cache (perf: avoid Players:GetPlayers() per AI tick) ────
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
for _, player in ipairs(Players:GetPlayers()) do
    table.insert(activePlayers, player)
end

-- ── Active enemy registry (so we can clean up at dawn) ────────────────────
local activeEnemies = {} -- [Model] = true

-- ── Template (cloned per spawn) ───────────────────────────────────────────
local enemyTemplate

local function buildEnemyTemplate()
    local model = Instance.new("Model")
    model.Name = "Enemy"

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.BrickColor = BrickColor.new("Really red")
    rootPart.Anchored = false
    rootPart.CanCollide = true
    rootPart.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    humanoid.Parent = model

    model.PrimaryPart = rootPart
    return model
end

-- Run the death VFX (anchor, fade out, destroy). Used both by Humanoid.Died
-- (player-killed) and by despawn-at-dawn (non-player cause). The
-- `awardRewards` flag is forwarded to CombatSystem so dawn cleanup doesn't
-- pay out kills.
local function performDeath(enemy, awardRewards)
    if not activeEnemies[enemy] then
        return -- Already despawned
    end
    activeEnemies[enemy] = nil

    if CombatSystem then
        CombatSystem.UnregisterEnemy(enemy, awardRewards)
    end

    local rootPart = enemy.PrimaryPart
    if rootPart then
        rootPart.Anchored = true
        rootPart.CanCollide = false

        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, { Transparency = 1 })
        tween:Play()
        tween.Completed:Wait()
    end
    enemy:Destroy()
end

local function findNearestPlayer(position)
    local nearestPlayer = nil
    local minDistanceSq = math.huge

    for _, player in ipairs(activePlayers) do
        local character = player.Character
        if character and character.PrimaryPart then
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

-- ── Touch damage ──────────────────────────────────────────────────────────
-- Per (enemy, player) cooldown so a single touch event doesn't drain a
-- player's HP from continuous Touched fires.
local function attachTouchDamage(enemy, humanoid, difficulty)
    local rootPart = enemy.PrimaryPart
    if not rootPart then
        return
    end

    local damage = TOUCH_DAMAGE + TOUCH_DAMAGE_PER_DIFFICULTY * math.max(1, difficulty)
    local lastHitAt = {} -- [UserId] = os.clock()

    rootPart.Touched:Connect(function(otherPart)
        if humanoid.Health <= 0 then
            return
        end
        local character = otherPart:FindFirstAncestorOfClass("Model")
        if not character then
            return
        end
        local victimHumanoid = character:FindFirstChildOfClass("Humanoid")
        if not victimHumanoid or victimHumanoid.Health <= 0 then
            return
        end
        local victimPlayer = Players:GetPlayerFromCharacter(character)
        if not victimPlayer then
            return -- Don't damage NPCs (residents) or other enemies
        end

        local now = os.clock()
        if (now - (lastHitAt[victimPlayer.UserId] or 0)) < TOUCH_DAMAGE_COOLDOWN_SECONDS then
            return
        end
        lastHitAt[victimPlayer.UserId] = now

        victimHumanoid:TakeDamage(damage)
    end)
end

-- ── Public API ────────────────────────────────────────────────────────────
function WaveManager.Init()
    print("[WaveManager] Initializing...")
    enemyTemplate = buildEnemyTemplate()
    -- Lazy-bind CombatSystem now that ServerMain has loaded both modules.
    CombatSystem = require(script.Parent.CombatSystem)

    -- Subscribe to phase transitions instead of being called directly by
    -- DayNightCycle. Same goes for BeastSystem, Phase 5 RaidManager, etc.
    local DayNightCycle = require(script.Parent.DayNightCycle)
    DayNightCycle.PhaseChangedBindable.Event:Connect(function(phase, dayCount)
        if phase == "Night" then
            WaveManager.StartWave(dayCount)
        end
    end)

    print("[WaveManager] Initialized.")
end

-- Despawn every active enemy. Called when the night phase ends.
function WaveManager.DespawnAll()
    local toKill = {}
    for enemy, _ in pairs(activeEnemies) do
        table.insert(toKill, enemy)
    end
    for _, enemy in ipairs(toKill) do
        task.spawn(performDeath, enemy, false)
    end
end

function WaveManager.StartWave(waveNumber)
    print(string.format("[WaveManager] Starting Wave %d...", waveNumber))

    task.spawn(function()
        local DayNightCycle = require(script.Parent.DayNightCycle)
        local elapsed = 0

        -- Loop in PHASE_CHECK_INTERVAL slices so we exit promptly at dawn
        -- (BUG-11: previously slept SPAWN_RATE seconds before checking).
        while DayNightCycle.Phase == "Night" do
            task.wait(PHASE_CHECK_INTERVAL)
            if DayNightCycle.Phase ~= "Night" then
                break
            end
            elapsed = elapsed + PHASE_CHECK_INTERVAL
            if elapsed >= SPAWN_RATE then
                elapsed = 0
                WaveManager.SpawnEnemy(waveNumber)
            end
        end

        -- Clean up any survivors so the day phase isn't haunted by leftovers.
        WaveManager.DespawnAll()
        print("[WaveManager] Wave ended; survivors despawned.")
    end)
end

function WaveManager.SpawnEnemy(difficulty)
    if not enemyTemplate then
        warn("[WaveManager] Not initialized")
        return
    end

    local enemy = enemyTemplate:Clone()
    local rootPart = enemy.PrimaryPart
    local humanoid = enemy:FindFirstChild("Humanoid")
    if not humanoid then
        enemy:Destroy()
        return
    end

    humanoid.MaxHealth = 100 + (difficulty * 10)
    humanoid.Health = humanoid.MaxHealth

    -- Death handling (player-killed). performDeath cleans up + awards loot.
    humanoid.Died:Connect(function()
        performDeath(enemy, true)
    end)

    -- Random spawn position (placeholder until Phase 2 map authoring)
    local startPos = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
    enemy:SetPrimaryPartCFrame(CFrame.new(startPos))
    enemy.Parent = workspace

    -- Register before any other module can ask "is this an enemy?"
    activeEnemies[enemy] = true
    if CombatSystem then
        CombatSystem.RegisterEnemy(enemy, difficulty)
    end

    attachTouchDamage(enemy, humanoid, difficulty)

    -- AI loop (pathfinding + LOS shortcut + variable update rate)
    task.spawn(function()
        local path = PathfindingService:CreatePath()
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = { enemy }

        while enemy.Parent and humanoid.Health > 0 do
            local targetPlayer = findNearestPlayer(rootPart.Position)
            local updateRate = 0.5

            if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
                local targetPos = targetPlayer.Character.PrimaryPart.Position
                local delta = targetPos - rootPart.Position
                local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z

                -- 🛡️ Sentinel: Use inverted comparison to prevent NaN coordinate spoofing from bypassing spatial checks
                if not (distSq <= 10000) then -- 100^2
                    updateRate = 2.0
                elseif not (distSq <= 2500) then -- 50^2
                    updateRate = 1.0
                end

                local usePathfinding = true
                if distSq < 900 then -- 30^2
                    rayParams.FilterDescendantsInstances = { enemy, targetPlayer.Character }
                    local direction = targetPos - rootPart.Position
                    local result = workspace:Raycast(rootPart.Position, direction, rayParams)
                    if not result then
                        usePathfinding = false
                    end
                end

                if usePathfinding then
                    local success, errorMessage = pcall(path.ComputeAsync, path, rootPart.Position, targetPos)
                    if success and path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        if #waypoints >= 2 then
                            humanoid:MoveTo(waypoints[2].Position)
                        else
                            humanoid:MoveTo(targetPos)
                        end
                    else
                        if not success then
                            warn("[WaveManager] Path computation failed:", errorMessage)
                        end
                        humanoid:MoveTo(targetPos)
                    end
                else
                    humanoid:MoveTo(targetPos)
                end
            end

            task.wait(updateRate)
        end
    end)
end

return WaveManager
