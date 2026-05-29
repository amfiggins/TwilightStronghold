--[[
    BeastDatabase.lua
    Definitions for every biome's main beast.

    Per docs/VISION.md §1.6, the beast is a fear / pressure / map-control
    mechanic — NOT a kill target. Beasts are unkillable in V1 (no Damage
    field, never registered with CombatSystem).

    Field reference:
      Name            string  - display name
      Biome           string  - matches MapManager biome key
      ModelHeight     number  - placeholder cube height in studs
      ModelRGB        {R,G,B} - placeholder cube tint as {0..255, 0..255, 0..255}
                                Stored as a triple instead of Color3 so this
                                module loads in pure-Lua environments (Lune
                                CI). Callers convert via Color3.fromRGB.
      WalkSpeed       number  - studs/sec when stalking
      ChaseSpeed      number  - studs/sec when hunting (Phase 4.3)
      StalkRangeMin   number  - hover at least this far from nearest player
      StalkRangeMax   number  - and at most this far
      GlimpseRange    number  - distance to dart in for a 'glimpse' (Phase 4.1)
      LightRetreat    number  - retreat to >= this distance from a BeastRepel
                                source (Phase 4.2)
      JumpScareDamage number  - HP dealt by a successful lunge (Phase 4.3)

    To add a new beast for a future biome:
      1. Add an entry below.
      2. Add the biome key to MapManager / map authoring.
      3. Tests in tests/lune/BeastDatabase.test.luau will fail loudly if
         the entry is missing required fields.
]]

local BeastDatabase = {}

local beasts = {
    ["wendigo"] = {
        Name = "Wendigo",
        Biome = "ForestKingdom",
        ModelHeight = 8,
        ModelRGB = { 40, 30, 25 },
        WalkSpeed = 12,
        ChaseSpeed = 22,
        StalkRangeMin = 50,
        StalkRangeMax = 100,
        GlimpseRange = 30,
        LightRetreat = 60,
        JumpScareDamage = 30,
    },
    -- Phase 8 work — defined but not wired into spawn logic yet.
    ["yeti"] = {
        Name = "Yeti",
        Biome = "FrozenTundra",
        ModelHeight = 10,
        ModelRGB = { 220, 230, 240 },
        WalkSpeed = 11,
        ChaseSpeed = 20,
        StalkRangeMin = 60,
        StalkRangeMax = 110,
        GlimpseRange = 35,
        LightRetreat = 70,
        JumpScareDamage = 35,
    },
    ["djinn_stalker"] = {
        Name = "Djinn Stalker",
        Biome = "DesertSultanate",
        ModelHeight = 9,
        ModelRGB = { 160, 110, 60 },
        WalkSpeed = 14,
        ChaseSpeed = 26,
        StalkRangeMin = 50,
        StalkRangeMax = 100,
        GlimpseRange = 25,
        LightRetreat = 55,
        JumpScareDamage = 28,
    },
}

-- Public API: get a beast by key.
function BeastDatabase.GetBeast(beastKey)
    return beasts[beastKey]
end

-- Public API: get the default beast for a biome.
-- Used by BeastSystem.Init when MapManager tells us which biome we loaded.
function BeastDatabase.GetBeastForBiome(biomeKey)
    for _, def in pairs(beasts) do
        if def.Biome == biomeKey then
            return def
        end
    end
    return nil
end

-- Public API: iterate. Read-only — callers must not mutate.
function BeastDatabase.GetAll()
    return beasts
end

return BeastDatabase
