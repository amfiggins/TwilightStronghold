--[[
    MapManager.lua
    Loads the Survival biome map from ServerStorage.Maps on server start.

    The Rojo project mounts assets/maps/ at ServerStorage.Maps so each
    .rbxm file authored in Studio appears as a child instance with the
    filename as its name.

    For now the loader hard-codes "ForestKingdom" — when we add Frozen
    Tundra and Desert Sultanate (Phases 6 and 8), this will pick the
    biome based on a deterministic hash of the MatchId so each squad's
    run picks one of the available biomes.

    If the requested map is missing (e.g., the level designer hasn't
    saved a .rbxm yet), MapManager logs a warning and continues. The
    server still boots and other systems run normally — you just won't
    have a map.
]]
local ServerStorage = game:GetService("ServerStorage")

local MapManager = {}

-- ── Config ────────────────────────────────────────────────────────────────
local DEFAULT_MAP_NAME = "ForestKingdom"

-- Where the loaded map lives once it's instantiated. Other systems
-- (resource respawn, structure persistence) place their content alongside
-- this so the world has a tidy hierarchy.
local LOADED_MAP_NAME = "Map"

-- ── State ─────────────────────────────────────────────────────────────────
MapManager.LoadedMap = nil

-- ── Helpers ───────────────────────────────────────────────────────────────
local function findSourceMap(mapName)
    local mapsFolder = ServerStorage:FindFirstChild("Maps")
    if not mapsFolder then
        return nil, "ServerStorage.Maps folder is missing — check default.project.json"
    end
    local source = mapsFolder:FindFirstChild(mapName)
    if not source then
        return nil, string.format("ServerStorage.Maps.%s not found — author the .rbxm in Studio", mapName)
    end
    return source
end

-- ── Public API ────────────────────────────────────────────────────────────
function MapManager.Init(mapName)
    mapName = mapName or DEFAULT_MAP_NAME

    -- Tear down any previous load (idempotent — useful if Init is ever
    -- called twice during dev).
    local existing = workspace:FindFirstChild(LOADED_MAP_NAME)
    if existing then
        existing:Destroy()
    end

    local source, reason = findSourceMap(mapName)
    if not source then
        warn(string.format("[MapManager] %s. Server will run without a map.", reason))
        return false
    end

    local clone = source:Clone()
    clone.Name = LOADED_MAP_NAME
    clone.Parent = workspace
    MapManager.LoadedMap = clone

    -- Count gather-able nodes for a quick startup sanity check. Anything
    -- with a ProximityPrompt named "Gather" is considered gather-able.
    local gatherable = 0
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "Gather" then
            gatherable = gatherable + 1
        end
    end

    print(string.format("[MapManager] Loaded '%s' with %d gather-able nodes.", mapName, gatherable))
    return true
end

return MapManager
