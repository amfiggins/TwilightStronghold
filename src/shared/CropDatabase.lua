--[[
    CropDatabase.lua
    Definitions for every plantable crop.

    Field reference:
      SeedItemId       string  - ItemDatabase id consumed when planting
      CropItemId       string  - ItemDatabase id awarded on harvest
      GrowthSeconds    number  - real-time seconds from plant → ready,
                                 measured only while the plot is watered
                                 (a dry plot pauses growth)
      WaterRequirement number  - total waterings needed before harvest
                                 (server tracks WaterCount per plot)
      Yield = { Min, Max }     - inclusive range of crops awarded on harvest
      Stages = { ... }         - ordered list of visual stage names; the plot
                                 cycles through these as growth progresses,
                                 and the last stage is "ready to harvest"
      PreferredBiomes (opt)    - { "ForestKingdom", ... } — metadata only;
                                 future Phase 5+ work will boost yield in
                                 preferred biomes

    To add a crop:
      1. Add a Seed item to ItemDatabase with Type = "Seed" and
         SeedFor = "<this CropDatabase key>"
      2. Add a Crop/Food item to ItemDatabase with Type = "Food"
         (or "Drink" / "Material" as appropriate) and a HungerRestore /
         ThirstRestore value if it's edible
      3. Add a CropDatabase entry below
      4. Add a test entry in tests/lune/CropDatabase.test.luau

    Tests in tests/lune/CropDatabase.test.luau will fail if any seed
    or crop ItemDatabase reference is missing, so you can't ship a
    half-wired entry.
]]

local CropDatabase = {}

local crops = {
    ["wheat"] = {
        SeedItemId = "wheat_seed",
        CropItemId = "wheat",
        GrowthSeconds = 480, -- 8 minutes
        WaterRequirement = 2,
        Yield = { Min = 2, Max = 4 },
        Stages = { "sprout", "leafy", "flowering", "ready" },
        PreferredBiomes = { "ForestKingdom" },
    },
    ["carrot"] = {
        SeedItemId = "carrot_seed",
        CropItemId = "carrot",
        GrowthSeconds = 360, -- 6 minutes
        WaterRequirement = 2,
        Yield = { Min = 1, Max = 3 },
        Stages = { "sprout", "leafy", "ready" },
        PreferredBiomes = { "ForestKingdom" },
    },
    ["berries"] = {
        SeedItemId = "berry_seed",
        CropItemId = "berries",
        GrowthSeconds = 600, -- 10 minutes (slow but high-yield bush)
        WaterRequirement = 3,
        Yield = { Min = 3, Max = 6 },
        Stages = { "sprout", "leafy", "flowering", "ready" },
        PreferredBiomes = { "ForestKingdom" },
    },
}

-- Public API: Get crop definition by key.
function CropDatabase.GetCrop(cropKey)
    return crops[cropKey]
end

-- Public API: Look up a crop by the seed's ItemDatabase id.
-- Used by FarmingSystem when the player fires PlantSeed(seedItemId).
function CropDatabase.GetCropForSeed(seedItemId)
    for _, def in pairs(crops) do
        if def.SeedItemId == seedItemId then
            return def
        end
    end
    return nil
end

-- Public API: iterate all defined crops. Returns the underlying table by
-- reference for performance — callers must not mutate it.
function CropDatabase.GetAll()
    return crops
end

return CropDatabase
