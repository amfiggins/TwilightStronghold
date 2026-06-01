--[[
    Item Database
    Stores definitions and attributes for all game items.
    Moved from GameConfig.lua for better scalability.
]]

local ItemDatabase = {}

local items = {
    -- Tools
    ["wooden_rod"] = {
        Name = "Wooden Rod",
        Type = "Tool",
        Rarity = "Common",
        Description = "A basic fishing rod.",
        Stackable = false,
    },
    ["iron_pickaxe"] = {
        Name = "Iron Pickaxe",
        Type = "Tool",
        Rarity = "Uncommon",
        Description = "Better than bare hands.",
        Stackable = false,
    },

    -- Light Sources
    -- BeastRepel : when present in the world (held tool, equipped attribute,
    --              or placed structure), pushes the beast away to LightRetreat
    --              studs. Phase 4.2 wires the detection in BeastSystem; Phase 5+
    --              will wire the held-tool path so a carried torch actually
    --              repels the beast.
    -- Per docs/VISION.md §1.6, torches must be found or crafted, not given
    -- to new players at spawn.
    ["torch"] = {
        Name = "Torch",
        Type = "Tool",
        Rarity = "Common",
        BeastRepel = true,
        Description = "A flickering torch. Beasts retreat from its light.",
        Stackable = false,
    },

    -- Weapons (Loadout Items)
    -- Damage   : hitpoints removed per swing
    -- Range    : max stud distance from attacker root to target root
    -- Cooldown : seconds between swings (server-enforced)
    ["wooden_sword"] = {
        Name = "Wooden Sword",
        Type = "Weapon",
        Rarity = "Common",
        Damage = 10,
        Range = 8,
        Cooldown = 0.6,
        Description = "Splintery but better than bare hands.",
        Stackable = false,
    },
    ["void_sword"] = {
        Name = "Void Slayer",
        Type = "Weapon",
        Rarity = "Legendary",
        Damage = 50,
        Range = 10,
        Cooldown = 0.5,
        Stackable = false,
    },

    -- Base Kits (Loadout Items)
    ["watchtower_kit"] = { Name = "Watchtower Blueprint", Type = "Kit", Rarity = "Rare", StructureId = "tower_01" },

    -- Bags (Inventory Capacity Upgrades)
    ["starter_bag"] = {
        Name = "Starter Bag",
        Type = "Bag",
        Rarity = "Common",
        Capacity = 10,
        Description = "A small bag.",
        Stackable = false,
    },
    ["leather_bag"] = {
        Name = "Leather Bag",
        Type = "Bag",
        Rarity = "Uncommon",
        Capacity = 20,
        Description = "A durable leather bag.",
        Stackable = false,
    },
    ["reinforced_bag"] = {
        Name = "Reinforced Bag",
        Type = "Bag",
        Rarity = "Rare",
        Capacity = 30,
        Description = "A reinforced bag with extra pockets.",
        Stackable = false,
    },

    -- Resources
    ["wood_log"] = { Name = "Wood Log", Type = "Material", Rarity = "Common", Description = "Basic building material." },
    ["golden_wood"] = { Name = "Golden Wood", Type = "Material", Rarity = "Rare", Description = "Shiny wood." },
    ["stone_ore"] = { Name = "Stone", Type = "Material", Rarity = "Common", Description = "A heavy rock." },

    -- Food & Drink
    -- HungerRestore : hunger points restored on eat (0–100 scale)
    -- ThirstRestore : thirst points restored on drink (0–100 scale)
    -- HealthRestore : HP restored on consume (optional)
    -- StomachAche   : if true, eating raw causes a brief debuff (future)
    ["raw_fish"] = {
        Name = "Raw Fish",
        Type = "Food",
        Rarity = "Common",
        HungerRestore = 10,
        StomachAche = true,
        Description = "Smells fishy. Eat cooked for better results.",
    },
    ["cooked_fish"] = {
        Name = "Cooked Fish",
        Type = "Food",
        Rarity = "Common",
        HungerRestore = 30,
        Description = "Properly cooked. Restores a decent amount of hunger.",
    },
    ["water_flask"] = {
        Name = "Water Flask",
        Type = "Drink",
        Rarity = "Common",
        ThirstRestore = 50,
        Description = "A flask of clean water.",
    },
    ["berries"] = {
        Name = "Berries",
        Type = "Food",
        Rarity = "Common",
        HungerRestore = 8,
        ThirstRestore = 5,
        Description = "Wild berries. Small but refreshing.",
    },

    -- Farming Crops (harvest yields)
    -- Crops with HungerRestore are also Food items so VitalsSystem.ConsumeItem
    -- accepts them with no extra wiring.
    ["wheat"] = {
        Name = "Wheat",
        Type = "Food",
        Rarity = "Common",
        HungerRestore = 6,
        Description = "Raw wheat. Bake into bread for better hunger restore.",
    },
    ["carrot"] = {
        Name = "Carrot",
        Type = "Food",
        Rarity = "Common",
        HungerRestore = 12,
        Description = "Crunchy and orange.",
    },

    -- Farming Seeds
    -- SeedFor : the CropDatabase key this seed grows into
    -- Tests verify every Seed has a matching CropDatabase entry whose
    -- SeedItemId points back here.
    ["wheat_seed"] = {
        Name = "Wheat Seed",
        Type = "Seed",
        Rarity = "Common",
        SeedFor = "wheat",
        Description = "Plant on a tilled plot. ~8 minutes to grow.",
    },
    ["carrot_seed"] = {
        Name = "Carrot Seed",
        Type = "Seed",
        Rarity = "Common",
        SeedFor = "carrot",
        Description = "Plant on a tilled plot. ~6 minutes to grow.",
    },
    ["berry_seed"] = {
        Name = "Berry Seed",
        Type = "Seed",
        Rarity = "Common",
        SeedFor = "berries",
        Description = "Plant on a tilled plot. Slow but high-yield.",
    },

    -- Farming Tools
    -- These are Tools (not Weapons / Kits) — used by FarmingSystem to gate
    -- Plant / Water / Harvest actions in Phase 3.3.
    ["hoe"] = {
        Name = "Hoe",
        Type = "Tool",
        Rarity = "Common",
        Description = "Tills soil so seeds can be planted.",
        Stackable = false,
    },
    ["watering_can"] = {
        Name = "Watering Can",
        Type = "Tool",
        Rarity = "Common",
        Description = "Waters planted crops to advance their growth.",
        Stackable = false,
    },
    ["fertilizer"] = {
        Name = "Fertilizer",
        Type = "Material",
        Rarity = "Uncommon",
        Description = "Applied to a planted plot to halve remaining growth time.",
    },
}

-- Public API: Get Item Definition
function ItemDatabase.GetItem(itemId)
    return items[itemId]
end

return ItemDatabase
