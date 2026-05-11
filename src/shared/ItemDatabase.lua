--[[
    Item Database
    Stores definitions and attributes for all game items.
    Moved from GameConfig.lua for better scalability.
]]

local ItemDatabase = {}

local items = {
    -- Tools
    ["wooden_rod"] = { Name = "Wooden Rod", Type = "Tool", Rarity = "Common", Description = "A basic fishing rod.", Stackable = false },
    ["iron_pickaxe"] = { Name = "Iron Pickaxe", Type = "Tool", Rarity = "Uncommon", Description = "Better than bare hands.", Stackable = false },

    -- Weapons (Loadout Items)
    ["void_sword"] = { Name = "Void Slayer", Type = "Weapon", Rarity = "Legendary", Damage = 50, Stackable = false },

    -- Base Kits (Loadout Items)
    ["watchtower_kit"] = { Name = "Watchtower Blueprint", Type = "Kit", Rarity = "Rare", StructureId = "tower_01" },

    -- Bags (Inventory Capacity Upgrades)
    ["starter_bag"] = { Name = "Starter Bag", Type = "Bag", Rarity = "Common", Capacity = 10, Description = "A small bag.", Stackable = false },
    ["leather_bag"] = { Name = "Leather Bag", Type = "Bag", Rarity = "Uncommon", Capacity = 20, Description = "A durable leather bag.", Stackable = false },
    ["reinforced_bag"] = { Name = "Reinforced Bag", Type = "Bag", Rarity = "Rare", Capacity = 30, Description = "A reinforced bag with extra pockets.", Stackable = false },

    -- Resources
    ["wood_log"] = { Name = "Wood Log", Type = "Material", Rarity = "Common", Description = "Basic building material." },
    ["golden_wood"] = { Name = "Golden Wood", Type = "Material", Rarity = "Rare", Description = "Shiny wood." },
    ["stone_ore"] = { Name = "Stone", Type = "Material", Rarity = "Common", Description = "A heavy rock." },
    ["raw_fish"] = { Name = "Raw Fish", Type = "Consumable", Rarity = "Common", Description = "Smells fishy." }
}

-- Public API: Get Item Definition
function ItemDatabase.GetItem(itemId)
    return items[itemId]
end

return ItemDatabase
