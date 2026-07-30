--[[
    CombatSystem.lua
    Server-authoritative combat. The client fires "Attack" with a target;
    the server validates the player has the claimed weapon equipped, that
    the target is in range, and that the per-weapon cooldown has elapsed.

    Two-way responsibilities split with WaveManager:
      - WaveManager registers each enemy via RegisterEnemy(model, difficulty).
      - CombatSystem applies damage, awards kill credit, and drops loot.
      - WaveManager hooks Humanoid.Died on the model and handles death VFX.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

local CombatSystem = {}

-- ── Internal state ────────────────────────────────────────────────────────
-- [Model] = { difficulty = number, killCredit = { [UserId] = damage } }
local enemies = {}
-- [UserId] = lastSwingClock (os.clock())
local lastSwingTimes = {}

-- Generous safety margin on top of the weapon's declared range so legitimate
-- swings near the edge aren't rejected by network latency. Cheaters have to
-- beat both the declared range and this margin to get a hit.
local RANGE_TOLERANCE_STUDS = 4

-- Reward formula (intentionally simple for Phase 1; tune later)
local function rewardFor(difficulty)
    return {
        rubies = 5 * math.max(1, difficulty),
        xp = 10 * math.max(1, difficulty),
    }
end

-- ── Remotes ───────────────────────────────────────────────────────────────
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackEvent = Instance.new("RemoteEvent")
AttackEvent.Name = "Attack"
AttackEvent.Parent = Remotes

-- ── Helpers ───────────────────────────────────────────────────────────────
local function getEquippedWeapon(player)
    local data = PlayerDataHandler.Get(player)
    if not data or not data.Loadout or not data.Loadout.Weapon then
        return nil, nil
    end
    local weaponId = data.Loadout.Weapon
    -- The loadout claims a weapon — make sure the player actually owns it.
    if not PlayerDataHandler.GetItem(player, weaponId) then
        return nil, nil
    end
    local def = ItemDatabase.GetItem(weaponId)
    if not def or def.Type ~= "Weapon" then
        return nil, nil
    end
    return weaponId, def
end

-- A "valid target" is a Model with a Humanoid that we registered as an enemy.
-- We deliberately do not allow attacking arbitrary humanoids (PvP is off at
-- launch; see docs/VISION.md §1.3).
local function getEnemyHumanoid(target)
    if typeof(target) ~= "Instance" or not target:IsA("Model") then
        return nil
    end
    if not enemies[target] then
        return nil
    end
    if not target.Parent or not target.PrimaryPart then
        return nil
    end
    local humanoid = target:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil
    end
    return humanoid
end

-- ── Public API ────────────────────────────────────────────────────────────

-- Called by WaveManager when an enemy is spawned.
function CombatSystem.RegisterEnemy(model, difficulty)
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        return
    end
    enemies[model] = {
        difficulty = difficulty or 1,
        killCredit = {},
    }
end

-- Called by WaveManager when an enemy is destroyed.
-- `awardRewards` defaults to true. Set to false for despawn-at-dawn or any
-- non-player cause where players shouldn't be paid.
function CombatSystem.UnregisterEnemy(model, awardRewards)
    local entry = enemies[model]
    if not entry then
        return
    end
    enemies[model] = nil

    if awardRewards == false then
        return
    end

    -- Award rewards proportional to damage contribution
    local reward = rewardFor(entry.difficulty)
    local totalDamage = 0
    for _, damage in pairs(entry.killCredit) do
        totalDamage = totalDamage + damage
    end
    if totalDamage <= 0 then
        return -- Enemy died from non-player cause
    end

    for userId, damage in pairs(entry.killCredit) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            local share = damage / totalDamage
            local rubies = math.max(1, math.floor(reward.rubies * share))
            PlayerDataHandler.AddCurrency(player, "Rubies", rubies)
            -- XP not yet wired into a leveling system; tracked as a stat.
            local data = PlayerDataHandler.Get(player)
            if data and data.Stats then
                data.Stats.XP = (data.Stats.XP or 0) + math.floor(reward.xp * share)
            end
        end
    end
end

-- Returns true if the model is a registered enemy (used by WaveManager and
-- future AI to gate damage application).
function CombatSystem.IsEnemy(model)
    return enemies[model] ~= nil
end

-- ── Init ──────────────────────────────────────────────────────────────────
function CombatSystem.Init()
    AttackEvent.OnServerEvent:Connect(function(player, target)
        local weaponId, weaponDef = getEquippedWeapon(player)
        if not weaponId then
            return -- No weapon → silent reject (keeps log spam down)
        end

        -- Per-weapon cooldown (server-authoritative rate limit)
        local now = os.clock()
        local last = lastSwingTimes[player.UserId] or 0
        if (now - last) < (weaponDef.Cooldown or 0.5) then
            return
        end
        lastSwingTimes[player.UserId] = now

        -- Validate target
        local humanoid = getEnemyHumanoid(target)
        if not humanoid then
            return
        end

        -- Range check (server-authoritative; client position is untrusted)
        local character = player.Character
        local rootPart = character and character.PrimaryPart
        if not rootPart then
            return -- Player dead/spawning
        end

        local maxRange = (weaponDef.Range or 6) + RANGE_TOLERANCE_STUDS
        local delta = target.PrimaryPart.Position - rootPart.Position
        local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
        -- 🛡️ Sentinel: Use inverted comparison to prevent NaN coordinate spoofing from bypassing the distance check
        if not (distSq <= maxRange * maxRange) then
            return
        end

        -- Apply damage
        local damage = weaponDef.Damage or 5
        humanoid:TakeDamage(damage)

        -- Track contribution for kill rewards
        local entry = enemies[target]
        if entry then
            entry.killCredit[player.UserId] = (entry.killCredit[player.UserId] or 0) + damage
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        lastSwingTimes[player.UserId] = nil
    end)

    print("[CombatSystem] Initialized.")
end

return CombatSystem
