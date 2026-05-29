--[[
    BeastSystem.lua
    Spawns and runs the biome's main beast during the Night phase.

    Per docs/VISION.md §1.6, the beast is a fear / pressure mechanic —
    NOT a kill target. It is intentionally:
      - never registered with CombatSystem (so player attacks have no
        target to validate against)
      - mostly invisible (Transparency 1) except during 'Glimpse' darts
      - unkillable (Humanoid.Health is checked but nothing damages it)

    State machine (V1, expanded in Phase 4.3):
        Stalk    -> hover between StalkRangeMin and StalkRangeMax studs
                    from the nearest player, walking around them
        Glimpse  -> briefly dart to GlimpseRange and fade in for 0.4s,
                    then back to Stalk

    Lifecycle:
      Init() registers a PhaseChanged listener so the beast spawns when
      night begins and despawns when day breaks.
      Only one beast per server (vision §1.7 covers sub-beasts; that's
      future work).

    Spawn point:
      Currently a fixed offset from origin. When MapManager grows a
      designated spawn point we'll read it from there. Phase 5's
      StrongholdLight will replace this with a real reference point.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BeastDatabase = require(ReplicatedStorage.Shared.BeastDatabase)

local BeastSystem = {}

-- ── Config ────────────────────────────────────────────────────────────────
-- Default beast key when MapManager doesn't tell us a biome (e.g., the
-- default flat baseplate playtest setup). Phase 4 ships with Wendigo only.
local DEFAULT_BEAST_KEY = "wendigo"

-- Stronghold reference point. Until Phase 5's StrongholdLight lands, we
-- use a fixed world position so 'distance from stronghold' calculations
-- have something concrete to work with. Tune freely.
local STRONGHOLD_CENTER = Vector3.new(0, 5, 0)

-- AI tick — how often the beast re-evaluates its move target. Cheap
-- since there's only one beast and it's bounded.
local TICK_INTERVAL_SECONDS = 0.6

-- Glimpse cadence: a Stalk-state beast initiates a Glimpse roughly every
-- (MIN, MAX) seconds. The randomization keeps players from learning a
-- predictable pattern.
local GLIMPSE_INTERVAL_MIN = 18
local GLIMPSE_INTERVAL_MAX = 35
local GLIMPSE_VISIBLE_SECONDS = 0.4
local GLIMPSE_TRANSPARENCY = 0.7

-- ── State ─────────────────────────────────────────────────────────────────
BeastSystem.Active = nil :: Model? -- the current beast instance, if any
local stateMachineThread = nil
local nextGlimpseAt = 0
local currentState = "Stalk" -- "Stalk" | "Glimpse"

-- ── Helpers ───────────────────────────────────────────────────────────────
local function rgbColor(rgb)
    return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function findNearestPlayer(position)
    local nearest = nil
    local minSq = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local rootPart = character and character.PrimaryPart
        if rootPart then
            local delta = rootPart.Position - position
            local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
            if distSq < minSq then
                minSq = distSq
                nearest = player
            end
        end
    end
    return nearest, math.sqrt(minSq)
end

-- Build a placeholder beast model. Studio art replaces this in a future
-- Phase by hand-authoring an .rbxm and updating BeastSystem.spawn to
-- clone from ServerStorage.Beasts.<biome>.
local function buildBeastModel(def)
    local model = Instance.new("Model")
    model.Name = "Beast_" .. def.Name

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, def.ModelHeight, 2)
    rootPart.Color = rgbColor(def.ModelRGB)
    rootPart.Material = Enum.Material.SmoothPlastic
    rootPart.Anchored = false
    rootPart.CanCollide = false -- so the beast doesn't shove players around
    rootPart.Massless = true
    rootPart.Transparency = 1 -- invisible by default; Glimpse fades it in
    rootPart.Parent = model

    local humanoid = Instance.new("Humanoid")
    -- The beast is unkillable in V1. We still need a Humanoid for MoveTo /
    -- pathfinding. Setting MaxHealth and Health absurdly high also means
    -- any incidental damage doesn't matter.
    humanoid.MaxHealth = 1e9
    humanoid.Health = 1e9
    humanoid.WalkSpeed = def.WalkSpeed
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.Parent = model

    model.PrimaryPart = rootPart
    return model
end

-- Pick a target position near `aroundPlayer` that satisfies the stalk
-- range constraint. Tries a few random angles and keeps the first that
-- lands on solid ground (via raycast down).
local function pickStalkTarget(aroundPlayer, def)
    local character = aroundPlayer.Character
    local root = character and character.PrimaryPart
    if not root then
        return nil
    end
    local center = root.Position
    local desired = (def.StalkRangeMin + def.StalkRangeMax) * 0.5
    for _ = 1, 4 do
        local angle = math.random() * math.pi * 2
        local candidate = center + Vector3.new(math.cos(angle) * desired, 0, math.sin(angle) * desired)
        -- Drop to ground level via a 200-stud downward ray.
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        if BeastSystem.Active then
            rayParams.FilterDescendantsInstances = { BeastSystem.Active }
        end
        local hit = workspace:Raycast(candidate + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), rayParams)
        if hit then
            return hit.Position + Vector3.new(0, def.ModelHeight * 0.5 + 0.5, 0)
        end
    end
    return center -- fallback: stand on the player (will resolve next tick)
end

-- Pick a glimpse-target a bit closer to the player so the player gets a
-- brief partial reveal at the edge of view.
local function pickGlimpseTarget(towardPlayer, def)
    local character = towardPlayer.Character
    local root = character and character.PrimaryPart
    if not root then
        return nil
    end
    local center = root.Position
    -- A point GlimpseRange studs from the player, roughly behind them.
    local angle = math.random() * math.pi * 2
    return center + Vector3.new(math.cos(angle) * def.GlimpseRange, 0, math.sin(angle) * def.GlimpseRange)
end

-- ── Glimpse behaviour ─────────────────────────────────────────────────────
local function performGlimpse(beast, def)
    if currentState ~= "Stalk" then
        return
    end
    local target = findNearestPlayer(beast.PrimaryPart.Position)
    if not target then
        return
    end

    currentState = "Glimpse"

    local destination = pickGlimpseTarget(target, def)
    if destination then
        local humanoid = beast:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(destination)
        end
    end

    -- Fade in briefly so the player gets the partial reveal.
    local rootPart = beast.PrimaryPart
    if rootPart then
        rootPart.Transparency = GLIMPSE_TRANSPARENCY
        task.delay(GLIMPSE_VISIBLE_SECONDS, function()
            if rootPart and rootPart.Parent then
                rootPart.Transparency = 1
            end
            currentState = "Stalk"
        end)
    else
        currentState = "Stalk"
    end

    -- Schedule the next glimpse.
    nextGlimpseAt = os.clock() + math.random(GLIMPSE_INTERVAL_MIN, GLIMPSE_INTERVAL_MAX)
end

-- ── State machine tick ────────────────────────────────────────────────────
local function tick(beast, def)
    if not beast.Parent then
        return
    end
    local rootPart = beast.PrimaryPart
    local humanoid = beast:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then
        return
    end

    -- If Stalking, possibly initiate a glimpse.
    if currentState == "Stalk" and os.clock() >= nextGlimpseAt then
        performGlimpse(beast, def)
        return
    end

    if currentState == "Stalk" then
        local nearest, dist = findNearestPlayer(rootPart.Position)
        if not nearest then
            return -- empty server; sit still
        end

        -- If we're outside the stalk band, always walk to a fresh target.
        -- If inside the band, only re-target ~30% of the time so the beast
        -- doesn't twitch on every tick — gives a more menacing 'pacing'
        -- feel.
        local mustMove = dist < def.StalkRangeMin or dist > def.StalkRangeMax
        if mustMove or math.random() < 0.3 then
            local target = pickStalkTarget(nearest, def)
            if target then
                humanoid:MoveTo(target)
            end
        end
    end
end

-- ── Spawn / despawn ───────────────────────────────────────────────────────
function BeastSystem.spawn(def)
    if BeastSystem.Active then
        return
    end

    local model = buildBeastModel(def)
    -- Spawn well outside the stronghold so the player doesn't see it pop in.
    local spawnAngle = math.random() * math.pi * 2
    local spawnDist = def.StalkRangeMax + 20
    local spawnPos = STRONGHOLD_CENTER
        + Vector3.new(math.cos(spawnAngle) * spawnDist, 0, math.sin(spawnAngle) * spawnDist)
    model:PivotTo(CFrame.new(spawnPos))
    model.Parent = workspace

    BeastSystem.Active = model
    currentState = "Stalk"
    nextGlimpseAt = os.clock() + math.random(GLIMPSE_INTERVAL_MIN, GLIMPSE_INTERVAL_MAX)

    print(string.format("[BeastSystem] %s has emerged.", def.Name))

    stateMachineThread = task.spawn(function()
        while BeastSystem.Active == model do
            local ok, err = pcall(tick, model, def)
            if not ok then
                warn(string.format("[BeastSystem] tick error: %s", tostring(err)))
            end
            task.wait(TICK_INTERVAL_SECONDS)
        end
    end)
end

function BeastSystem.despawn()
    local active = BeastSystem.Active
    if not active then
        return
    end
    BeastSystem.Active = nil
    if stateMachineThread then
        -- The thread checks Active and exits naturally.
        stateMachineThread = nil
    end
    print("[BeastSystem] Beast retreats with the dawn.")
    active:Destroy()
end

-- ── Init ──────────────────────────────────────────────────────────────────
function BeastSystem.Init()
    -- Subscribe to phase transitions via the server-side bindable on
    -- DayNightCycle. Spawn at night, despawn at day.
    local DayNightCycle = require(script.Parent.DayNightCycle)
    DayNightCycle.PhaseChangedBindable.Event:Connect(function(phase)
        if phase == "Night" then
            local def = BeastDatabase.GetBeast(DEFAULT_BEAST_KEY)
            if def then
                BeastSystem.spawn(def)
            end
        else
            BeastSystem.despawn()
        end
    end)

    print("[BeastSystem] Initialized. Awaiting nightfall.")
end

return BeastSystem
