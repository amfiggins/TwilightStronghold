--[[
    FarmingSystem.lua
    Server-authoritative handlers for the three farming verbs:
        PlantSeed(plot, seedItemId)
        WaterCrop(plot)
        HarvestCrop(plot)

    All three:
      - rate-limit per player (0.5s) per the existing security pattern
      - validate the plot is in the workspace and tagged as a player structure
      - validate the player is within FARMING_RANGE studs
      - validate the plot's PlotState matches the action (server is source
        of truth on every transition; clients only fire the remote)

    State model (attributes on the plot Part):
        PlotState     "tilled" | "planted" | "ready"
        CropKey       CropDatabase key (e.g. "wheat") or ""
        WateringCount integer
        PlantedAt     os.time() when planted, or 0
        Stage         visual stage from CropDatabase[crop].Stages
                      (driven by PlotManager's growth tick)

    Why the split with PlotManager:
        FarmingSystem owns user actions (Plant / Water / Harvest) — what
        flips PlotState. PlotManager owns the world-tick consequences —
        advancing Stage as time passes, flipping PlotState to "ready"
        when both watering and time conditions are met. This keeps each
        module's state transitions easy to reason about.
]]
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)
local CropDatabase = require(ReplicatedStorage.Shared.CropDatabase)

local FarmingSystem = {}

-- ── Config ────────────────────────────────────────────────────────────────
local ACTION_COOLDOWN = 0.5
local FARMING_RANGE_STUDS = 12 -- max distance from player root to plot

-- Tag set in BuildingSystem on every player-built structure. Plots are a
-- subset; we additionally check Name == "Plot".
local STRUCTURE_TAG = "TwilightStronghold_PlayerStructure"

-- ── Per-player rate limiting ──────────────────────────────────────────────
local lastActionAt = {} -- [UserId] = os.clock()

local function checkRateLimit(player)
    local now = os.clock()
    local last = lastActionAt[player.UserId] or 0
    if (now - last) < ACTION_COOLDOWN then
        return false
    end
    lastActionAt[player.UserId] = now
    return true
end

-- ── Plot validation ───────────────────────────────────────────────────────
-- Returns the plot Part if `target` is a valid in-range plot, else nil.
local function validatePlot(player, target)
    if typeof(target) ~= "Instance" or not target:IsDescendantOf(workspace) then
        return nil
    end
    if not target:IsA("BasePart") then
        return nil
    end
    if target.Name ~= "Plot" then
        return nil
    end
    if not CollectionService:HasTag(target, STRUCTURE_TAG) then
        return nil
    end

    local character = player.Character
    local rootPart = character and character.PrimaryPart
    if not rootPart then
        return nil
    end

    local delta = rootPart.Position - target.Position
    local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
    if not (distSq <= FARMING_RANGE_STUDS * FARMING_RANGE_STUDS) then
        return nil
    end

    return target
end

-- ── Action handlers ───────────────────────────────────────────────────────
local function onPlantSeed(player, target, seedItemId)
    if not checkRateLimit(player) then
        return
    end
    if type(seedItemId) ~= "string" then
        return
    end

    local plot = validatePlot(player, target)
    if not plot then
        return
    end
    if plot:GetAttribute("PlotState") ~= "tilled" then
        return -- Plot already has a crop on it
    end

    local seedDef = ItemDatabase.GetItem(seedItemId)
    if not seedDef or seedDef.Type ~= "Seed" then
        return
    end

    local cropDef = CropDatabase.GetCropForSeed(seedItemId)
    if not cropDef then
        return -- Seed has no matching crop (shouldn't happen — tested in CI)
    end

    -- Verify ownership and consume one seed.
    if not PlayerDataHandler.GetItem(player, seedItemId) then
        return
    end
    if not PlayerDataHandler.RemoveItem(player, seedItemId, 1) then
        return
    end

    -- Use crop key as the canonical id (CropDatabase keys equal CropItemId).
    plot:SetAttribute("CropKey", cropDef.CropItemId)
    plot:SetAttribute("WateringCount", 0)
    plot:SetAttribute("PlantedAt", os.time())
    plot:SetAttribute("Stage", cropDef.Stages[1]) -- e.g. "sprout"
    plot:SetAttribute("PlotState", "planted") -- triggers PlotManager prompt swap

    print(string.format("[FarmingSystem] %s planted %s on a plot", player.Name, tostring(seedDef.Name or seedItemId)))
end

local function onWaterCrop(player, target)
    if not checkRateLimit(player) then
        return
    end

    local plot = validatePlot(player, target)
    if not plot then
        return
    end
    if plot:GetAttribute("PlotState") ~= "planted" then
        return
    end

    local cropKey = plot:GetAttribute("CropKey")
    local cropDef = cropKey and CropDatabase.GetCrop(cropKey)
    if not cropDef then
        return
    end

    local current = plot:GetAttribute("WateringCount") or 0
    if current >= cropDef.WaterRequirement then
        return -- Already fully watered
    end

    plot:SetAttribute("WateringCount", current + 1)
    print(
        string.format(
            "[FarmingSystem] %s watered a %s plot (%d/%d)",
            player.Name,
            cropKey,
            current + 1,
            cropDef.WaterRequirement
        )
    )
end

local function onHarvestCrop(player, target)
    if not checkRateLimit(player) then
        return
    end

    local plot = validatePlot(player, target)
    if not plot then
        return
    end
    if plot:GetAttribute("PlotState") ~= "ready" then
        return -- Not grown yet
    end

    local cropKey = plot:GetAttribute("CropKey")
    local cropDef = cropKey and CropDatabase.GetCrop(cropKey)
    if not cropDef then
        return
    end

    -- Roll the yield range and add to inventory. If inventory is full, we
    -- still succeed with whatever fits — the rest is wasted (matches the
    -- Resource gathering pattern).
    local qty = math.random(cropDef.Yield.Min, cropDef.Yield.Max)
    PlayerDataHandler.AddItem(player, cropDef.CropItemId, qty)

    -- Reset plot to tilled so the player can replant. We deliberately do
    -- NOT keep the plot type-locked — any seed can be planted next.
    plot:SetAttribute("CropKey", "")
    plot:SetAttribute("WateringCount", 0)
    plot:SetAttribute("PlantedAt", 0)
    plot:SetAttribute("Stage", "")
    plot:SetAttribute("PlotState", "tilled")

    print(string.format("[FarmingSystem] %s harvested %d %s", player.Name, qty, tostring(cropDef.CropItemId)))
end

-- ── Init ──────────────────────────────────────────────────────────────────
function FarmingSystem.Init()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    local plant = Instance.new("RemoteEvent")
    plant.Name = "PlantSeed"
    plant.Parent = Remotes

    local water = Instance.new("RemoteEvent")
    water.Name = "WaterCrop"
    water.Parent = Remotes

    local harvest = Instance.new("RemoteEvent")
    harvest.Name = "HarvestCrop"
    harvest.Parent = Remotes

    plant.OnServerEvent:Connect(onPlantSeed)
    water.OnServerEvent:Connect(onWaterCrop)
    harvest.OnServerEvent:Connect(onHarvestCrop)

    Players.PlayerRemoving:Connect(function(player)
        lastActionAt[player.UserId] = nil
    end)

    print("[FarmingSystem] Initialized.")
end

return FarmingSystem
