--[[
    SoundConfig.lua
    Centralised mapping from logical sound keys to Roblox asset IDs.

    Why centralise:
      - swapping an asset (e.g., licensing change) is a one-line edit
      - tests catch missing keys before they hit production
      - we can stub IDs to "" during development; clients log a warning
        and play silence rather than crashing

    Categories so far:
      Beast.*  - Phase 4.2 layered horror audio (footstep, breathing, etc.)

    Asset IDs are placeholders pointing at the Roblox free sound library.
    Replace with curated assets when the audio team has them.
]]

local SoundConfig = {}

local sounds = {
    -- ── Beast (Phase 4.2) ────────────────────────────────────────────────
    -- Distance-bucketed cues that play under, breathing, and growl tiers
    -- as the beast closes on the player.
    ["Beast.Footstep"] = {
        AssetId = "rbxassetid://9118823179", -- forest-floor footstep
        Volume = 0.6,
        RollOffMaxDistance = 60,
    },
    ["Beast.BranchSnap"] = {
        AssetId = "rbxassetid://9119001284",
        Volume = 0.7,
        RollOffMaxDistance = 80,
    },
    ["Beast.Breathing"] = {
        AssetId = "rbxassetid://9118827083",
        Volume = 0.5,
        RollOffMaxDistance = 35,
        Looped = true,
    },
    ["Beast.Growl"] = {
        AssetId = "rbxassetid://9118835651",
        Volume = 0.8,
        RollOffMaxDistance = 25,
    },
    ["Beast.AmbientHowl"] = {
        AssetId = "rbxassetid://9118839472",
        Volume = 0.4,
        RollOffMaxDistance = 200,
    },
    ["Beast.ChaseMusic"] = {
        AssetId = "rbxassetid://9118842917",
        Volume = 0.6,
        Looped = true,
    },
}

-- Public API: get a sound definition by key. Returns nil for unknown keys.
function SoundConfig.Get(key)
    return sounds[key]
end

-- Public API: iterate. Read-only — callers must not mutate.
function SoundConfig.GetAll()
    return sounds
end

return SoundConfig
