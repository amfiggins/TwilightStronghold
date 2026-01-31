--[[
    MinigameController.lua
    Manages the "Fisch-style" minigame UI and logic.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MinigameController = {}
local player = Players.LocalPlayer
local gui = nil
local frame = nil
local bar = nil
local target = nil
local progressBar = nil

local isPlaying = false
local progress = 0
local barPosition = 0
local targetPosition = 0.5
local successCallback = nil

-- Constants
local BAR_SIZE = 0.2 -- 20% of the area
local TARGET_SIZE = 0.15
local DECAY_RATE = 0.2
local FILL_RATE = 0.5
local TARGET_SPEED = 0.5

function MinigameController.Init()
    -- Create UI Programmatically
    gui = Instance.new("ScreenGui")
    gui.Name = "MinigameUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(0, 300, 0, 40)
    bg.Position = UDim2.new(0.5, -150, 0.8, 0)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bg.BorderSizePixel = 2
    bg.Visible = false
    bg.Parent = gui
    frame = bg
    
    target = Instance.new("Frame")
    target.Name = "Target"
    target.Size = UDim2.new(TARGET_SIZE, 0, 1, 0)
    target.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    target.BackgroundTransparency = 0.5
    target.Parent = bg
    
    bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(BAR_SIZE, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.Parent = bg

    -- Progress Bar Background (UX Improvement)
    local pBg = Instance.new("Frame")
    pBg.Name = "ProgressBg"
    pBg.Size = UDim2.new(1, 0, 0, 4)
    pBg.Position = UDim2.new(0, 0, 1, 4) -- 4px below main bar
    pBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    pBg.BorderSizePixel = 0
    pBg.Parent = bg

    -- Progress Bar Fill
    progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressFill"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = pBg
end

function MinigameController.Start(callback)
    if isPlaying then return end
    isPlaying = true
    successCallback = callback
    progress = 0
    barPosition = 0.5
    
    frame.Visible = true
    
    -- Game Loop
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then
            connection:Disconnect()
            frame.Visible = false
            return
        end
        
        -- Logic: Move Bar with Spacebar
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            barPosition = math.min(1 - BAR_SIZE, barPosition + (1.5 * dt))
        else
            barPosition = math.max(0, barPosition - (1.0 * dt))
        end
        
        -- Move Target (Random/Sine wave in future, just static/slow for now)
        -- targetPosition = 0.5 + math.sin(tick()) * 0.3
        
        -- Update UI
        bar.Position = UDim2.new(barPosition, 0, 0, 0)
        target.Position = UDim2.new(targetPosition, 0, 0, 0)
        
        -- Check Overlap
        local barStart = barPosition
        local barEnd = barPosition + BAR_SIZE
        local targetStart = targetPosition
        local targetEnd = targetPosition + TARGET_SIZE
        
        if barStart < targetEnd and barEnd > targetStart then
            progress = progress + (FILL_RATE * dt)
        else
            progress = math.max(0, progress - (DECAY_RATE * dt))
        end
        
        -- Update Progress Bar
        if progressBar then
            progressBar.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end

        -- Check Win/Loss
        if progress >= 1 then
            MinigameController.Stop(true)
        end
    end)
end

function MinigameController.Stop(success)
    isPlaying = false
    frame.Visible = false
    if success and successCallback then
        successCallback()
    end
end

return MinigameController
