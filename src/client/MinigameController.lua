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
local instructionLabel = nil

local isPlaying = false
local progress = 0
local barPosition = 0
local targetPosition = 0.5
local successCallback = nil

local activeTouches = 0
local isMousePressed = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches = activeTouches + 1
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMousePressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches = math.max(0, activeTouches - 1)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMousePressed = false
    end
end)

local function updateInstructionText()
    if not instructionLabel then return end
    local lastInputType = UserInputService:GetLastInputType()
    if lastInputType == Enum.UserInputType.Touch then
        instructionLabel.Text = "Hold <b>SCREEN</b> to align"
    elseif lastInputType.Name:match("Gamepad") then
        instructionLabel.Text = "Hold <b>RIGHT TRIGGER</b> to align"
    else
        instructionLabel.Text = "Hold <b>SPACE/CLICK</b> to align"
    end
end

UserInputService.LastInputTypeChanged:Connect(function()
    updateInstructionText()
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
    instruction.Text = "Hold <b>SPACE/CLICK</b> to align"
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
    instructionLabel = instruction

    updateInstructionText()
end

function MinigameController.Start(callback)
    if isPlaying then return end
    isPlaying = true
    successCallback = callback
    progress = 0
    barPosition = 0.5
    
    frame.Visible = true
    if progressFill then
        progressFill.Size = UDim2.new(0, 0, 1, 0)
    end
    
    -- Game Loop
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then
            connection:Disconnect()
            frame.Visible = false
            return
        end
        
        -- Logic: Move Bar with Multi-Platform Inputs
        local isInputActive = UserInputService:IsKeyDown(Enum.KeyCode.Space) or
                              isMousePressed or
                              activeTouches > 0 or
                              (UserInputService:GetLastInputType().Name:match("Gamepad") and UserInputService:IsGamepadButtonDown(UserInputService:GetLastInputType(), Enum.KeyCode.ButtonR2))

        if isInputActive then
            barPosition = math.min(1 - BAR_SIZE, barPosition + (1.5 * dt))
        else
            barPosition = math.max(0, barPosition - (1.0 * dt))
        end
        
        -- Move Target (Random/Sine wave in future, just static/slow for now)
        -- targetPosition = 0.5 + math.sin(tick()) * 0.3
        
        -- Update UI
        bar.Position = UDim2.new(barPosition, 0, 0, 0)
        target.Position = UDim2.new(targetPosition, 0, 0, 0)
        if progressFill then
            progressFill.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        end
        
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
