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
local progressFill = nil

local isPlaying = false
local progress = 0
local barPosition = 0
local targetPosition = 0.5
local successCallback = nil
local instructionLabel = nil
local activeTouches = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if instructionLabel then instructionLabel.Text = "Hold <b>SPACE</b> to align" end
    elseif input.UserInputType.Name:match("Gamepad") then
        if instructionLabel then instructionLabel.Text = "Hold <b>A Button</b> to align" end
    elseif input.UserInputType == Enum.UserInputType.Touch then
        activeTouches = activeTouches + 1
        if instructionLabel then instructionLabel.Text = "<b>Hold screen</b> to align" end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        if instructionLabel then instructionLabel.Text = "<b>Hold Click</b> to align" end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches = math.max(0, activeTouches - 1)
    end
end)

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

    -- Progress Bar
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBackground"
    progressBg.Size = UDim2.new(1, 0, 0, 8)
    progressBg.Position = UDim2.new(0, 0, 1, 5)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg

    progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg

    -- Micro-UX: Instruction Label
    local instruction = Instance.new("TextLabel")
    instructionLabel = instruction
    if UserInputService.TouchEnabled then
        instruction.Text = "<b>Hold screen</b> to align"
    elseif UserInputService.GamepadEnabled then
        instruction.Text = "Hold <b>A Button</b> to align"
    else
        instruction.Text = "Hold <b>SPACE</b> or <b>Click</b> to align"
    end
    instruction.RichText = true
    instruction.Size = UDim2.new(1, 0, 0, 30)
    instruction.AnchorPoint = Vector2.new(0, 1) -- Bottom-Left
    instruction.Position = UDim2.new(0, 0, 0, -5) -- 5px above
    instruction.BackgroundTransparency = 1
    instruction.TextColor3 = Color3.fromRGB(255, 255, 255)
    instruction.TextStrokeTransparency = 0.5
    instruction.Font = Enum.Font.GothamBold
    instruction.TextSize = 18
    instruction.Parent = bg
end

function MinigameController.Start(callback)
    if isPlaying then return end
    isPlaying = true
    successCallback = callback
    progress = 0
    barPosition = 0.5
    
    -- Reset bar color on start
    if bar then
        bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    frame.Visible = true
    if progressFill then
        -- Optimization: Use fromScale instead of new
        progressFill.Size = UDim2.fromScale(0, 1)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    end
    
    -- Game Loop
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then
            connection:Disconnect()
            frame.Visible = false
            return
        end
        
        -- Logic: Move Bar with Multi-Platform Input
        local isInputActive = false
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            isInputActive = true
        elseif UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            isInputActive = true
        elseif activeTouches > 0 then
            isInputActive = true
        else
            for _, gamepad in ipairs(UserInputService:GetConnectedGamepads()) do
                if UserInputService:IsGamepadButtonDown(gamepad, Enum.KeyCode.ButtonA) then
                    isInputActive = true
                    break
                end
            end
        end

        if isInputActive then
            barPosition = math.min(1 - BAR_SIZE, barPosition + (1.5 * dt))
        else
            barPosition = math.max(0, barPosition - (1.0 * dt))
        end
        
        -- Move Target (Random/Sine wave in future, just static/slow for now)
        -- targetPosition = 0.5 + math.sin(tick()) * 0.3
        
        -- Update UI
        -- Optimization: Use UDim2.fromScale in hot paths to skip unused property parsing
        bar.Position = UDim2.fromScale(barPosition, 0)
        target.Position = UDim2.fromScale(targetPosition, 0)
        if progressFill then
            progressFill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
        end
        
        -- Check Overlap
        local barStart = barPosition
        local barEnd = barPosition + BAR_SIZE
        local targetStart = targetPosition
        local targetEnd = targetPosition + TARGET_SIZE
        
        if barStart < targetEnd and barEnd > targetStart then
            progress = progress + (FILL_RATE * dt)
            -- Visual feedback: highlight bar when overlapping target
            if bar then
                bar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            end
            if progressFill then
                progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            end
        else
            progress = math.max(0, progress - (DECAY_RATE * dt))
            -- Visual feedback: reset bar color when not overlapping
            if bar then
                bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
            if progressFill then
                if progress > 0 then
                    progressFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                else
                    progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                end
            end
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
