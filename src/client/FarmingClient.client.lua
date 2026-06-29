--[[
    FarmingClient.client.lua
    Survival-only. Bridges the player's inputs to the FarmingSystem
    RemoteEvents created in Phase 3.3.

    Responsibilities:
      - On the Plant prompt: open a seed-selector ScreenGui filtered to
        seeds the player currently owns. Picking a seed fires PlantSeed.
      - On the Water and Harvest prompts: fire the corresponding remote
        immediately (no UI needed — those actions are unambiguous).
      - Hover tooltip: when the player's mouse is over a planted plot,
        show a small "Wheat — 6:23 remaining" overlay.

    All farming validation lives on the server. The client is just an
    input adapter and a status display.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local CropDatabase = require(ReplicatedStorage.Shared.CropDatabase)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Bail out in Lobby — the FarmingSystem remotes only exist in Survival.
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlantSeedEvent = Remotes:WaitForChild("PlantSeed", 10)
if not PlantSeedEvent then
    print("[FarmingClient] No PlantSeed remote (Lobby mode). Idle.")
    return
end
local WaterCropEvent = Remotes:WaitForChild("WaterCrop", 5)
local HarvestCropEvent = Remotes:WaitForChild("HarvestCrop", 5)
local GetPlayerData = Remotes:WaitForChild("GetPlayerData", 5)

-- ── Seed selector UI ──────────────────────────────────────────────────────
local selectorGui = nil :: ScreenGui?
local selectorOpen = false

local function closeSelector()
    if selectorGui then
        selectorGui:Destroy()
        selectorGui = nil
    end
    selectorOpen = false
end

local function openSelector(plot)
    if selectorOpen then
        return
    end
    selectorOpen = true

    -- Fetch the player's inventory once on open (cheap — we already
    -- rate-limit GetPlayerData on the server).
    local ok, data = pcall(function()
        return GetPlayerData:InvokeServer()
    end)
    if not ok or not data then
        warn("[FarmingClient] Failed to fetch inventory for seed selector")
        selectorOpen = false
        return
    end

    -- Filter to seeds the player owns. We also confirm the seed has a
    -- matching CropDatabase entry so a stale ItemDatabase entry can't
    -- show up as a planting option.
    local ownedSeeds = {}
    for _, slot in ipairs(data.Inventory or {}) do
        local def = ItemDatabase.GetItem(slot.ItemId)
        if def and def.Type == "Seed" and (slot.Qty or 0) > 0 then
            local cropDef = CropDatabase.GetCropForSeed(slot.ItemId)
            if cropDef then
                table.insert(ownedSeeds, {
                    itemId = slot.ItemId,
                    name = def.Name or slot.ItemId,
                    qty = slot.Qty,
                    description = def.Description,
                    growthSeconds = cropDef.GrowthSeconds,
                })
            end
        end
    end

    -- Build the GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "SeedSelector"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    selectorGui = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(280, 240)
    frame.Position = UDim2.new(0.5, -140, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Text = "Plant a Seed"
    title.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Text = "✕"
    closeBtn.Parent = frame

    local function updateCloseState(isHovered)
        closeBtn.TextColor3 = isHovered and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    end
    closeBtn.MouseEnter:Connect(function()
        updateCloseState(true)
    end)
    closeBtn.MouseLeave:Connect(function()
        updateCloseState(false)
    end)
    closeBtn.SelectionGained:Connect(function()
        updateCloseState(true)
    end)
    closeBtn.SelectionLost:Connect(function()
        updateCloseState(false)
    end)

    closeBtn.MouseButton1Click:Connect(closeSelector)

    -- Scroll list
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -16, 1, -48)
    list.Position = UDim2.fromOffset(8, 40)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    if #ownedSeeds == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 60)
        empty.BackgroundTransparency = 1
        empty.TextColor3 = Color3.fromRGB(180, 180, 180)
        empty.Font = Enum.Font.SourceSansItalic
        empty.TextSize = 14
        empty.TextWrapped = true
        empty.Text = "No seeds in your inventory.\nGather or trade for some first."
        empty.Parent = list
    else
        for _, seed in ipairs(ownedSeeds) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.RichText = true
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left

            local minutes = math.floor(seed.growthSeconds / 60)
            btn.Text = string.format(
                "  <b>%s</b>  ×%d\n  <font size='11' color='#BBBBBB'>~%d min growth</font>",
                seed.name,
                seed.qty,
                minutes
            )

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local function updateBtnState(isHovered)
                btn.BackgroundColor3 = isHovered and Color3.fromRGB(80, 100, 80) or Color3.fromRGB(60, 60, 60)
            end
            btn.MouseEnter:Connect(function()
                updateBtnState(true)
            end)
            btn.MouseLeave:Connect(function()
                updateBtnState(false)
            end)
            btn.SelectionGained:Connect(function()
                updateBtnState(true)
            end)
            btn.SelectionLost:Connect(function()
                updateBtnState(false)
            end)

            btn.MouseButton1Click:Connect(function()
                PlantSeedEvent:FireServer(plot, seed.itemId)
                closeSelector()
            end)

            btn.Parent = list
        end
    end
end

-- ── Prompt routing ────────────────────────────────────────────────────────
ProximityPromptService.PromptTriggered:Connect(function(prompt, triggerPlayer)
    if triggerPlayer ~= player then
        return
    end
    -- Only respond to prompts on plots. Defensive — Roblox could deliver
    -- prompts on any tagged instance and we don't want to misroute.
    local plot = prompt.Parent
    if not plot or not plot:IsA("BasePart") or plot.Name ~= "Plot" then
        return
    end

    if prompt.Name == "Plant" then
        openSelector(plot)
    elseif prompt.Name == "Water" then
        if WaterCropEvent then
            WaterCropEvent:FireServer(plot)
        end
    elseif prompt.Name == "Harvest" then
        if HarvestCropEvent then
            HarvestCropEvent:FireServer(plot)
        end
    end
end)

-- ── Hover tooltip ─────────────────────────────────────────────────────────
local tooltipGui = Instance.new("ScreenGui")
tooltipGui.Name = "FarmingTooltip"
tooltipGui.ResetOnSpawn = false
tooltipGui.Parent = player:WaitForChild("PlayerGui")

local tooltipLabel = Instance.new("TextLabel")
tooltipLabel.Size = UDim2.fromOffset(220, 38)
tooltipLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tooltipLabel.BackgroundTransparency = 0.2
tooltipLabel.BorderSizePixel = 0
tooltipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltipLabel.Font = Enum.Font.GothamBold
tooltipLabel.TextSize = 13
tooltipLabel.RichText = true
tooltipLabel.Visible = false
tooltipLabel.Parent = tooltipGui

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 6)
tooltipCorner.Parent = tooltipLabel

local function formatRemaining(seconds)
    local s = math.max(0, math.floor(seconds))
    if s >= 60 then
        return string.format("%d:%02d remaining", math.floor(s / 60), s % 60)
    end
    return string.format("%ds remaining", s)
end

RunService.RenderStepped:Connect(function()
    local target = mouse.Target
    if not target or target.Name ~= "Plot" then
        tooltipLabel.Visible = false
        return
    end
    -- Don't show the tooltip if we're far away (avoids clutter when
    -- looking at a distant plot).
    local character = player.Character
    local rootPart = character and character.PrimaryPart
    if not rootPart then
        tooltipLabel.Visible = false
        return
    end
    local delta = rootPart.Position - target.Position
    if delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z > 400 then -- 20 studs
        tooltipLabel.Visible = false
        return
    end

    local state = target:GetAttribute("PlotState")
    local cropKey = target:GetAttribute("CropKey")
    local cropDef = cropKey and cropKey ~= "" and CropDatabase.GetCrop(cropKey)
    local cropItem = cropDef and ItemDatabase.GetItem(cropDef.CropItemId)
    local cropName = (cropItem and cropItem.Name) or cropKey

    local text
    if state == "tilled" then
        text = "<b>Empty plot</b>\n<font size='11' color='#BBBBBB'>Press the prompt to plant a seed</font>"
    elseif state == "ready" then
        text = string.format("<b>%s</b>\n<font size='11' color='#FFD66A'>Ready to harvest</font>", cropName or "Crop")
    elseif state == "planted" and cropDef then
        local plantedAt = target:GetAttribute("PlantedAt") or 0
        local watering = target:GetAttribute("WateringCount") or 0
        local timeRemaining = (plantedAt + cropDef.GrowthSeconds) - os.time()
        local needsWater = watering < cropDef.WaterRequirement
        if needsWater then
            text = string.format(
                "<b>%s</b>\n<font size='11' color='#79B8FF'>Water %d / %d</font>",
                cropName or "Crop",
                watering,
                cropDef.WaterRequirement
            )
        else
            text = string.format(
                "<b>%s</b>\n<font size='11' color='#BBBBBB'>%s</font>",
                cropName or "Crop",
                formatRemaining(timeRemaining)
            )
        end
    else
        tooltipLabel.Visible = false
        return
    end

    tooltipLabel.Text = text
    tooltipLabel.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 16)
    tooltipLabel.Visible = true
end)

print("[FarmingClient] Initialized.")
