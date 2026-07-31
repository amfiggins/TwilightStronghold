--[[
    SurvivalHUD.client.lua
    Survival-only. Renders three status bars (Health, Hunger, Thirst) and a
    phase/day label with a countdown timer.

    Data sources:
      - Health: polled from LocalPlayer.Character.Humanoid each RenderStepped
      - Hunger/Thirst: updated via VitalsUpdate RemoteEvent from VitalsSystem
      - Phase/Day/Timer: updated via PhaseChanged RemoteEvent from DayNightCycle
      - Day 150 milestone: Day150Reached RemoteEvent shows a one-time banner

    Layout (all programmatic, no Studio assets required):
      Top-center: [Phase label]  Day N  [countdown]
      Bottom-left: ❤ [Health bar]  🍖 [Hunger bar]  💧 [Thirst bar]
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Bail out in Lobby (VitalsUpdate and PhaseChanged remotes won't exist)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local VitalsUpdateEvent = Remotes:WaitForChild("VitalsUpdate", 10)
if not VitalsUpdateEvent then
    print("[SurvivalHUD] No VitalsUpdate remote (Lobby mode). Idle.")
    return
end
local PhaseChangedEvent = Remotes:WaitForChild("PhaseChanged", 5)
local Day150ReachedEvent = Remotes:WaitForChild("Day150Reached", 5)

-- ── Colours ───────────────────────────────────────────────────────────────
local COLOR_HEALTH = Color3.fromRGB(220, 60, 60)
local COLOR_HUNGER = Color3.fromRGB(210, 140, 50)
local COLOR_THIRST = Color3.fromRGB(60, 140, 220)
local COLOR_DAY = Color3.fromRGB(255, 220, 80)
local COLOR_NIGHT = Color3.fromRGB(100, 120, 220)
local COLOR_BAR_BG = Color3.fromRGB(30, 30, 30)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)

-- ── State ─────────────────────────────────────────────────────────────────
local vitals = { Hunger = 100, Thirst = 100, MaxHunger = 100, MaxThirst = 100 }
local phaseState = { phase = "Day", dayCount = 1, timeRemaining = 300 }

-- ── Build UI ──────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "SurvivalHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- ── Helper: create a labelled bar ─────────────────────────────────────────
local function makeBar(parent, icon, color, yOffset)
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(180, 18)
    container.Position = UDim2.new(0, 12, 1, yOffset)
    container.AnchorPoint = Vector2.new(0, 1)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = icon
    iconLabel.Size = UDim2.fromOffset(20, 18)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = COLOR_TEXT
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 14
    iconLabel.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -24, 1, 0)
    bg.Position = UDim2.fromOffset(24, 0)
    bg.BackgroundColor3 = COLOR_BAR_BG
    bg.BorderSizePixel = 0
    bg.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    return fill
end

-- ── Bottom-left bars ──────────────────────────────────────────────────────
local healthFill = makeBar(gui, "❤", COLOR_HEALTH, -8)
local hungerFill = makeBar(gui, "🍖", COLOR_HUNGER, -32)
local thirstFill = makeBar(gui, "💧", COLOR_THIRST, -56)

-- ── Top-center phase / day / timer ────────────────────────────────────────
local topFrame = Instance.new("Frame")
topFrame.Size = UDim2.fromOffset(260, 36)
topFrame.Position = UDim2.new(0.5, -130, 0, 8)
topFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topFrame.BackgroundTransparency = 0.4
topFrame.BorderSizePixel = 0
topFrame.Parent = gui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topFrame

local phaseLabel = Instance.new("TextLabel")
phaseLabel.Name = "PhaseLabel"
phaseLabel.Size = UDim2.fromScale(0.35, 1)
phaseLabel.BackgroundTransparency = 1
phaseLabel.TextColor3 = COLOR_DAY
phaseLabel.Font = Enum.Font.GothamBold
phaseLabel.TextSize = 14
phaseLabel.Text = "☀ Day"
phaseLabel.Parent = topFrame

local dayLabel = Instance.new("TextLabel")
dayLabel.Name = "DayLabel"
dayLabel.Size = UDim2.fromScale(0.3, 1)
dayLabel.Position = UDim2.fromScale(0.35, 0)
dayLabel.BackgroundTransparency = 1
dayLabel.TextColor3 = COLOR_TEXT
dayLabel.Font = Enum.Font.GothamBold
dayLabel.TextSize = 14
dayLabel.Text = "Day 1"
dayLabel.Parent = topFrame

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.fromScale(0.35, 1)
timerLabel.Position = UDim2.fromScale(0.65, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = COLOR_TEXT
timerLabel.Font = Enum.Font.Gotham
timerLabel.TextSize = 13
timerLabel.Text = "5:00"
timerLabel.Parent = topFrame

-- ── Update helpers ────────────────────────────────────────────────────────
-- ⚡ Bolt: Cache static TweenInfo to prevent object allocation every call
local barTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

local function setBarFill(fill, ratio)
    local clamped = math.clamp(ratio, 0, 1)
    TweenService:Create(fill, barTweenInfo, {
        Size = UDim2.fromScale(clamped, 1),
    }):Play()
end

local function formatTime(seconds)
    local s = math.max(0, math.floor(seconds))
    return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

local function updatePhaseLabel()
    if phaseState.phase == "Night" then
        phaseLabel.Text = "🌙 Night"
        phaseLabel.TextColor3 = COLOR_NIGHT
    else
        phaseLabel.Text = "☀ Day"
        phaseLabel.TextColor3 = COLOR_DAY
    end
    dayLabel.Text = "Day " .. tostring(phaseState.dayCount)
    timerLabel.Text = formatTime(phaseState.timeRemaining)
end

-- ── Day 150 milestone banner ──────────────────────────────────────────────
local function showMilestoneBanner()
    local banner = Instance.new("Frame")
    banner.Size = UDim2.fromOffset(400, 80)
    banner.Position = UDim2.new(0.5, -200, 0.4, 0)
    banner.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    banner.BackgroundTransparency = 0.1
    banner.BorderSizePixel = 0
    banner.ZIndex = 20
    banner.Parent = gui

    local bannerCorner = Instance.new("UICorner")
    bannerCorner.CornerRadius = UDim.new(0, 12)
    bannerCorner.Parent = banner

    local bannerText = Instance.new("TextLabel")
    bannerText.Size = UDim2.fromScale(1, 1)
    bannerText.BackgroundTransparency = 1
    bannerText.TextColor3 = Color3.fromRGB(30, 20, 0)
    bannerText.Font = Enum.Font.GothamBold
    bannerText.TextSize = 22
    bannerText.RichText = true
    bannerText.Text = "🏆 <b>Night 150 Reached!</b>\nEndless mode unlocked — keep surviving!"
    bannerText.ZIndex = 21
    bannerText.Parent = banner

    -- Fade out after 5 seconds
    task.delay(5, function()
        TweenService:Create(banner, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(bannerText, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1,
        }):Play()
        task.wait(1.6)
        banner:Destroy()
    end)
end

-- ── Event listeners ───────────────────────────────────────────────────────
VitalsUpdateEvent.OnClientEvent:Connect(function(newVitals)
    vitals = newVitals
    setBarFill(hungerFill, vitals.Hunger / vitals.MaxHunger)
    setBarFill(thirstFill, vitals.Thirst / vitals.MaxThirst)
end)

if PhaseChangedEvent then
    PhaseChangedEvent.OnClientEvent:Connect(function(phase, dayCount, timeRemaining)
        phaseState.phase = phase
        phaseState.dayCount = dayCount
        phaseState.timeRemaining = timeRemaining
        updatePhaseLabel()
    end)
end

if Day150ReachedEvent then
    Day150ReachedEvent.OnClientEvent:Connect(showMilestoneBanner)
end

-- ── RenderStepped: health bar + timer countdown ───────────────────────────
local lastHealthRatio = -1
local lastTimerSeconds = -1

RunService.RenderStepped:Connect(function(dt)
    -- Health bar
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local targetRatio = humanoid.Health / math.max(1, humanoid.MaxHealth)
        -- ⚡ Bolt: Cache health ratio to avoid Tween creation overhead every frame
        if targetRatio ~= lastHealthRatio then
            lastHealthRatio = targetRatio
            setBarFill(healthFill, targetRatio)
        end
    end

    -- Countdown (client-side interpolation between server ticks)
    phaseState.timeRemaining = math.max(0, phaseState.timeRemaining - dt)
    local currentTimerSeconds = math.max(0, math.floor(phaseState.timeRemaining))

    -- ⚡ Bolt: Cache formatted time to prevent string allocation and UI update overhead every frame
    if currentTimerSeconds ~= lastTimerSeconds then
        lastTimerSeconds = currentTimerSeconds
        timerLabel.Text = formatTime(phaseState.timeRemaining)
    end
end)

print("[SurvivalHUD] Initialized.")
