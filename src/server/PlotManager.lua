--[[
    PlotManager.lua
    Two responsibilities:

    1. Per-plot ProximityPrompts. Each plot gets exactly one of three
       prompts (Plant / Water / Harvest), driven by its PlotState attribute.
       PlotManager subscribes to GetAttributeChangedSignal so prompts swap
       reactively when FarmingSystem (or the growth tick) flips state.

    2. Server-wide growth tick. Every TICK_INTERVAL_SECONDS, iterate every
       planted plot. For each:
         * advance the visual Stage attribute based on elapsed-time fraction
           through cropDef.GrowthSeconds
         * if the plot is fully watered AND the full GrowthSeconds has
           elapsed, flip PlotState to "ready"
         * also recolour the plot for placeholder visual feedback (V1)

    This module attaches itself to existing plots via CollectionService,
    so plots placed AFTER PlotManager.Init() are automatically picked up.
]]
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropDatabase = require(ReplicatedStorage.Shared.CropDatabase)

local PlotManager = {}

-- ── Config ────────────────────────────────────────────────────────────────
local STRUCTURE_TAG = "TwilightStronghold_PlayerStructure"
local TICK_INTERVAL_SECONDS = 5
-- Prompt sit-distance (matches FarmingSystem's 12-stud range loosely;
-- ProximityPrompt itself enforces this, server still revalidates).
local PROMPT_DISTANCE = 8
local PROMPT_HOLD = 0.4

-- Placeholder colours for the four growth states (V1 — Phase 3.4 Studio
-- art will replace these with stage models).
local COLOR_BY_STAGE = {
    tilled = Color3.fromRGB(95, 65, 35), -- brown soil
    sprout = Color3.fromRGB(120, 150, 70), -- pale green
    leafy = Color3.fromRGB(70, 140, 60), -- mid green
    flowering = Color3.fromRGB(120, 200, 80), -- bright green
    ready = Color3.fromRGB(220, 180, 50), -- gold
}

-- ── Internal state ────────────────────────────────────────────────────────
-- [Plot] = { connections = { ... } } so we can disconnect on removal.
local managed = {}

-- ── Prompt helpers ────────────────────────────────────────────────────────
local PROMPT_NAMES = { "Plant", "Water", "Harvest" }

local function ensurePrompt(plot, name)
    local existing = plot:FindFirstChild(name)
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end
    if existing then
        existing:Destroy()
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.ActionText = name
    prompt.ObjectText = "Plot"
    prompt.MaxActivationDistance = PROMPT_DISTANCE
    prompt.HoldDuration = PROMPT_HOLD
    prompt.RequiresLineOfSight = false
    prompt.Enabled = false
    prompt.Parent = plot
    return prompt
end

-- Show only the prompt(s) appropriate for the plot's current state.
local function refreshPrompts(plot)
    local state = plot:GetAttribute("PlotState") or "tilled"
    local crop = plot:GetAttribute("CropKey")
    local cropDef = crop and crop ~= "" and CropDatabase.GetCrop(crop)
    local fullyWatered = cropDef and (plot:GetAttribute("WateringCount") or 0) >= cropDef.WaterRequirement

    -- Decide which prompt is visible. Only one is enabled at a time so
    -- players don't see conflicting affordances.
    local active = nil
    if state == "tilled" then
        active = "Plant"
    elseif state == "planted" and not fullyWatered then
        active = "Water"
    elseif state == "ready" then
        active = "Harvest"
    end
    -- "planted" + fully watered + not ready yet: no prompt; the player
    -- has done their part and just needs to wait.

    for _, name in ipairs(PROMPT_NAMES) do
        local prompt = plot:FindFirstChild(name)
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt.Enabled = (name == active)
        end
    end
end

-- ── Visual stage / colour ─────────────────────────────────────────────────
local function refreshVisuals(plot)
    local state = plot:GetAttribute("PlotState") or "tilled"
    local stage = plot:GetAttribute("Stage")
    local key
    if state == "tilled" then
        key = "tilled"
    elseif state == "ready" then
        key = "ready"
    elseif stage and COLOR_BY_STAGE[stage] then
        key = stage
    else
        key = "sprout"
    end
    local color = COLOR_BY_STAGE[key]
    if color and plot:IsA("BasePart") then
        plot.Color = color
    end
end

-- ── Plot lifecycle ────────────────────────────────────────────────────────
local function attachPlot(plot)
    if managed[plot] then
        return
    end
    if plot.Name ~= "Plot" then
        return
    end

    -- Create the three prompts upfront so refreshPrompts just toggles
    -- Enabled. Cheaper than churning them on every state change.
    for _, name in ipairs(PROMPT_NAMES) do
        ensurePrompt(plot, name)
    end

    local conns = {}
    table.insert(
        conns,
        plot:GetAttributeChangedSignal("PlotState"):Connect(function()
            refreshPrompts(plot)
            refreshVisuals(plot)
        end)
    )
    table.insert(
        conns,
        plot:GetAttributeChangedSignal("WateringCount"):Connect(function()
            refreshPrompts(plot)
        end)
    )
    table.insert(
        conns,
        plot:GetAttributeChangedSignal("Stage"):Connect(function()
            refreshVisuals(plot)
        end)
    )
    table.insert(
        conns,
        plot.AncestryChanged:Connect(function(_, parent)
            if not parent then
                -- Plot was destroyed (or moved out of workspace). Clean up.
                for _, conn in ipairs(conns) do
                    conn:Disconnect()
                end
                managed[plot] = nil
            end
        end)
    )

    managed[plot] = { connections = conns }
    refreshPrompts(plot)
    refreshVisuals(plot)
end

-- ── Growth tick ───────────────────────────────────────────────────────────
local function tick()
    for plot, _ in pairs(managed) do
        if plot.Parent and plot:GetAttribute("PlotState") == "planted" then
            local cropKey = plot:GetAttribute("CropKey")
            local cropDef = cropKey and CropDatabase.GetCrop(cropKey)
            if cropDef then
                local plantedAt = plot:GetAttribute("PlantedAt") or 0
                local elapsed = os.time() - plantedAt
                local fraction = math.clamp(elapsed / cropDef.GrowthSeconds, 0, 1)

                -- Advance visual stage based on elapsed-time fraction.
                -- Stages are evenly spaced across the growth window. The
                -- final "ready" stage is only set when WateringCount is
                -- met, even if time has already elapsed.
                local stages = cropDef.Stages
                -- Stages excludes the final "ready" while we're still
                -- "planted"; the ready visual is set when state flips.
                local nonReadyCount = #stages - 1 -- number of pre-ready stages
                if nonReadyCount < 1 then
                    nonReadyCount = 1
                end
                local stageIndex = math.clamp(math.floor(fraction * nonReadyCount) + 1, 1, nonReadyCount)
                local newStage = stages[stageIndex]
                if newStage and plot:GetAttribute("Stage") ~= newStage then
                    plot:SetAttribute("Stage", newStage)
                end

                -- Flip to ready if both gates are met.
                local watering = plot:GetAttribute("WateringCount") or 0
                if fraction >= 1 and watering >= cropDef.WaterRequirement then
                    plot:SetAttribute("Stage", stages[#stages]) -- "ready"
                    plot:SetAttribute("PlotState", "ready")
                end
            end
        end
    end
end

-- ── Init ──────────────────────────────────────────────────────────────────
function PlotManager.Init()
    -- Attach to existing tagged instances and to anything that gets the
    -- tag in the future. CollectionService handles both cases via
    -- GetTagged + GetInstanceAddedSignal.
    for _, instance in ipairs(CollectionService:GetTagged(STRUCTURE_TAG)) do
        if instance:IsA("BasePart") and instance.Name == "Plot" then
            attachPlot(instance)
        end
    end
    CollectionService:GetInstanceAddedSignal(STRUCTURE_TAG):Connect(function(instance)
        if instance:IsA("BasePart") and instance.Name == "Plot" then
            attachPlot(instance)
        end
    end)

    -- Single server-wide growth tick. Cheap because we only iterate plots
    -- we manage (typically a few dozen) and only process those in the
    -- "planted" state.
    task.spawn(function()
        while true do
            task.wait(TICK_INTERVAL_SECONDS)
            local ok, err = pcall(tick)
            if not ok then
                warn(string.format("[PlotManager] tick error: %s", tostring(err)))
            end
        end
    end)

    print("[PlotManager] Initialized.")
end

return PlotManager
