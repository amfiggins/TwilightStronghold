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
Shared.INVENTORY_CAPACITY = 30 -- Max unique slots

-- Place Configuration
Shared.PLACE_IDS = {
    Lobby = 140360553864312, -- Twilight Stronghold - Lobby
    SurvivalZone = 114856846700519 -- Survival Zone
}

-- Structure Costs
Shared.StructureCosts = {
    ["Wall"] = { Resource = "wood_log", Amount = 5 },
    ["Tower"] = { Resource = "wood_log", Amount = 20 }
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
    ["Tree"] = { Item = "wood_log", Min = 1, Max = 3, RareItem = "golden_wood", RareChance = 5, DestroyOnGather = true },
    ["Rock"] = { Item = "stone_ore", Min = 1, Max = 2, DestroyOnGather = true },
    ["Lake"] = { Item = "raw_fish", Min = 1, Max = 1 }
}

-- Mapping: Specific Node Name -> Generic Resource ID
Shared.NodeTypeMapping = {
    ["OakTree"] = "Tree",
    ["BirchTree"] = "Tree",
    ["PineTree"] = "Tree",
    ["PalmTree"] = "Tree",
    ["WillowTree"] = "Tree",
    ["Boulder"] = "Rock",
    ["Limestone"] = "Rock",
    ["Granite"] = "Rock",
    ["Basalt"] = "Rock",
    ["Pond"] = "Lake",
    ["River"] = "Lake"
}

-- Item Database (Mock-up)
-- Item Database moved to ItemDatabase.lua
-- Shared.Items = require(script.Parent.ItemDatabase) -- Optional: If needed for back-compat

return Shared
