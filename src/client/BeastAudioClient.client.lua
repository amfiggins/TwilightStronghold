--[[
    BeastAudioClient.client.lua
    Layered horror audio for the beast. Listens to BeastNearby fired by
    BeastSystem and plays distance-bucketed sounds.

    Per docs/VISION.md §1.6, audio is the primary channel for beast
    presence — players should hear footsteps, breathing, and growls
    before they ever see the beast.

    Sound sources are attached to invisible probe parts that follow the
    player at controlled offsets. Roblox 3D-pans them based on the part
    position, giving a sense of direction without anchoring the audio
    to the (mostly invisible) beast itself.

    Tiers (from BeastSystem.tierForDistance):
      none      no audio
      far       ambient howl
      footstep  ambient howl + footsteps + branch snaps
      breathing  + breathing loop
      growl       + growl
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundConfig = require(ReplicatedStorage.Shared.SoundConfig)

local player = Players.LocalPlayer

-- Bail out in Lobby. The BeastNearby remote only exists in Survival.
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BeastNearbyEvent = Remotes:WaitForChild("BeastNearby", 10)
if not BeastNearbyEvent then
    print("[BeastAudioClient] No BeastNearby remote (Lobby mode). Idle.")
    return
end

-- ── Probe parts ───────────────────────────────────────────────────────────
-- A small invisible part that holds 3D-positioned sounds. We update its
-- CFrame each tier change so the panning roughly matches the beast's
-- direction without giving away exact location.
local probesFolder = Instance.new("Folder")
probesFolder.Name = "BeastAudioProbes"
probesFolder.Parent = workspace

local function newProbe(name)
    local part = Instance.new("Part")
    part.Name = "Probe_" .. name
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Transparency = 1
    part.Parent = probesFolder
    return part
end

local probes = {
    footstep = newProbe("Footstep"),
    breathing = newProbe("Breathing"),
    growl = newProbe("Growl"),
    ambient = newProbe("Ambient"),
}

-- ── Build sounds from SoundConfig ─────────────────────────────────────────
local function attachSound(parent, key)
    local def = SoundConfig.Get(key)
    if not def then
        warn(string.format("[BeastAudioClient] Missing SoundConfig key: %s", key))
        return nil
    end
    local sound = Instance.new("Sound")
    sound.Name = key
    sound.SoundId = def.AssetId
    sound.Volume = def.Volume or 0.5
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    if def.RollOffMaxDistance then
        sound.RollOffMaxDistance = def.RollOffMaxDistance
    end
    sound.Looped = def.Looped or false
    sound.Parent = parent
    return sound
end

local sounds = {
    ambient = attachSound(probes.ambient, "Beast.AmbientHowl"),
    footstep = attachSound(probes.footstep, "Beast.Footstep"),
    branchSnap = attachSound(probes.footstep, "Beast.BranchSnap"),
    breathing = attachSound(probes.breathing, "Beast.Breathing"),
    growl = attachSound(probes.growl, "Beast.Growl"),
}

-- ── Probe positioning ─────────────────────────────────────────────────────
-- We don't know the beast's exact position client-side (kept hidden by
-- design). Approximate by pushing each probe in a random direction
-- around the player at the tier's nominal radius. This still gives
-- convincing 3D pan without leaking the beast's position.
local TIER_DISTANCES = {
    far = 80,
    footstep = 40,
    breathing = 22,
    growl = 10,
}

local function reposition(tier)
    local character = player.Character
    local root = character and character.PrimaryPart
    if not root then
        return
    end
    local distance = TIER_DISTANCES[tier] or 40
    local angle = math.random() * math.pi * 2
    local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
    local pos = root.Position + offset
    for _, probe in pairs(probes) do
        probe.CFrame = CFrame.new(pos)
    end
end

-- ── Tier behaviour ────────────────────────────────────────────────────────
local function stopAll()
    for _, sound in pairs(sounds) do
        if sound and sound.IsPlaying then
            sound:Stop()
        end
    end
end

local function playOnce(sound)
    if sound then
        sound:Play()
    end
end

local function ensureLooping(sound)
    if sound and not sound.IsPlaying then
        sound:Play()
    end
end

local function applyTier(tier)
    if tier == "none" then
        stopAll()
        return
    end

    reposition(tier)

    -- Ambient howl plays in every active tier as a low background.
    ensureLooping(sounds.ambient)

    -- Footstep tier: occasional one-shots. Random which fires per call.
    if tier == "footstep" or tier == "breathing" or tier == "growl" then
        if math.random() < 0.6 then
            playOnce(sounds.footstep)
        else
            playOnce(sounds.branchSnap)
        end
    end

    -- Breathing loop: only when breathing or growl tier.
    if tier == "breathing" or tier == "growl" then
        ensureLooping(sounds.breathing)
    elseif sounds.breathing and sounds.breathing.IsPlaying then
        sounds.breathing:Stop()
    end

    -- Growl: only at the closest tier, played as a one-shot.
    if tier == "growl" then
        playOnce(sounds.growl)
    end
end

-- Make ambient looping on first play.
if sounds.ambient then
    sounds.ambient.Looped = true
end

BeastNearbyEvent.OnClientEvent:Connect(applyTier)

print("[BeastAudioClient] Initialized.")
