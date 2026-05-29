--[[
    StructurePersistence.lua
    Persists player-built structures across server restarts.

    Layout:
      - On every successful BuildingSystem.PlaceStructure, AddStructure() is
        called. We append a record to an in-memory list and schedule a save.
      - Saves are debounced (5s) so a build spree doesn't hammer the
        DataStore. Final flush happens on BindToClose.
      - On Survival server start, Init() loads the saved list and
        re-instantiates each structure via the BuildingSystem's renderer.

    Persistence key:
      - Today: "Structures_v" .. GAME_VERSION .. "_" .. PlaceId
        (one shared base per Place — simplest model that works for the
        current single-stronghold-per-server design).
      - Future: when MatchmakingService teleports squads with a real
        MatchId in TeleportData, switch to per-MatchId keys so each
        squad gets their own independent base.

    Record shape:
      { structureType = "Wall", cf = {12 components}, ownerUserId = 123 }
]]
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local StructurePersistence = {}

-- ── Config ────────────────────────────────────────────────────────────────
local SAVE_DEBOUNCE_SECONDS = 5
local DATASTORE_NAME = "Structures_v" .. GameConfig.GAME_VERSION
local KEY = "Place_" .. tostring(game.PlaceId)

local store = DataStoreService:GetDataStore(DATASTORE_NAME)

-- ── Internal state ────────────────────────────────────────────────────────
local records = {} -- { record, ... }
local dirty = false
local pendingSave = nil
local rendererCallback -- (record) -> Instance | nil

-- ── Helpers ───────────────────────────────────────────────────────────────
local function packCFrame(cf)
    return { cf:GetComponents() }
end

local function unpackCFrame(components)
    if type(components) ~= "table" or #components ~= 12 then
        return nil
    end
    return CFrame.new(table.unpack(components))
end

local function performSave()
    pendingSave = nil
    if not dirty then
        return
    end
    dirty = false

    local snapshot = table.clone(records)

    local ok, err = pcall(function()
        store:SetAsync(KEY, snapshot)
    end)
    if not ok then
        warn(string.format("[StructurePersistence] Save failed: %s", tostring(err)))
        dirty = true -- Try again later
    end
end

local function scheduleSave()
    dirty = true
    if pendingSave then
        return
    end
    pendingSave = task.delay(SAVE_DEBOUNCE_SECONDS, performSave)
end

-- ── Public API ────────────────────────────────────────────────────────────

-- Register the function the persistence layer will call to actually
-- materialise a saved structure (BuildingSystem provides this so we don't
-- have a require cycle and so all rendering goes through one path).
function StructurePersistence.SetRenderer(callback)
    rendererCallback = callback
end

-- Called by BuildingSystem after a successful place.
function StructurePersistence.AddStructure(structureType, cframe, ownerUserId)
    table.insert(records, {
        structureType = structureType,
        cf = packCFrame(cframe),
        ownerUserId = ownerUserId,
    })
    scheduleSave()
end

-- Init: load saved records and ask the renderer to instantiate each.
-- Called from ServerMain in Survival mode AFTER BuildingSystem.Init.
function StructurePersistence.Init()
    -- Cross-server playtests would race on a single shared key. In Studio
    -- we still want to test load/save logic, so we don't gate on IsStudio.
    local ok, saved = pcall(function()
        return store:GetAsync(KEY)
    end)
    if not ok then
        warn(string.format("[StructurePersistence] Load failed: %s", tostring(saved)))
        saved = nil
    end

    if type(saved) == "table" then
        local restored = 0
        for _, record in ipairs(saved) do
            local cf = unpackCFrame(record.cf)
            if cf and rendererCallback then
                local ok2, instance = pcall(rendererCallback, {
                    structureType = record.structureType,
                    cframe = cf,
                    ownerUserId = record.ownerUserId,
                })
                if ok2 and instance then
                    -- Keep the in-memory record so subsequent saves include it.
                    table.insert(records, record)
                    restored = restored + 1
                else
                    warn(string.format("[StructurePersistence] Renderer failed for %s", tostring(record.structureType)))
                end
            end
        end
        print(string.format("[StructurePersistence] Restored %d structures.", restored))
    else
        print("[StructurePersistence] No saved structures (fresh world).")
    end

    -- Final flush on shutdown so an unsaved build spree isn't lost.
    -- Skip in Studio because BindToClose blocks Play Solo for the timeout.
    if not RunService:IsStudio() then
        game:BindToClose(function()
            if dirty then
                performSave()
            end
        end)
    end
end

return StructurePersistence
