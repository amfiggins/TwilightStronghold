--[[
    Shared Constants & Configuration
    Stores game-wide settings, item definitions, and rarity tables.
]]

local Shared = {}

-- Game Configuration
Shared.GAME_VERSION = "0.1.0-alpha"
Shared.IS_SURVIVAL_MODE = false -- Toggle to true to test Survival Loop in Studio
Shared.MAX_LOBBY_PLAYERS = 20
Shared.MAX_SESSION_PLAYERS = 4 -- Survival squad size

-- Place Configuration
Shared.PLACE_IDS = {
    Lobby = 00000000, -- Replace with actual Lobby Place ID
    SurvivalZone = 11111111 -- Replace with actual Survival Place ID
}

-- Rarity Definitions
Shared.Rarity = {
    Common = { Name = "Common", Color = Color3.fromRGB(200, 200, 200), Chance = 100 },
    Uncommon = { Name = "Uncommon", Color = Color3.fromRGB(50, 255, 50), Chance = 25 },
    Rare = { Name = "Rare", Color = Color3.fromRGB(50, 100, 255), Chance = 10 },
    Epic = { Name = "Epic", Color = Color3.fromRGB(150, 0, 255), Chance = 2 },
    Legendary = { Name = "Legendary", Color = Color3.fromRGB(255, 150, 0), Chance = 0.5 },
    Mythic = { Name = "Mythic", Color = Color3.fromRGB(255, 0, 0), Chance = 0.01 },
}

-- Resource Definitions (Loot Tables)
Shared.Resources = {
    ["Tree"] = { Item = "wood_log", Min = 1, Max = 3 },
    ["Rock"] = { Item = "stone_ore", Min = 1, Max = 2 },
    ["Lake"] = { Item = "raw_fish", Min = 1, Max = 1 }
}

-- Item Database (Mock-up)
Shared.Items = {
    -- Tools
    ["wooden_rod"] = { Name = "Wooden Rod", Type = "Tool", Rarity = "Common", Description = "A basic fishing rod." },
    ["iron_pickaxe"] = { Name = "Iron Pickaxe", Type = "Tool", Rarity = "Uncommon", Description = "Better than bare hands." },
    
    -- Weapons (Loadout Items)
    ["void_sword"] = { Name = "Void Slayer", Type = "Weapon", Rarity = "Legendary", Damage = 50 },
    
    -- Base Kits (Loadout Items)
    ["watchtower_kit"] = { Name = "Watchtower Blueprint", Type = "Kit", Rarity = "Rare", StructureId = "tower_01" }
}

return Shared
