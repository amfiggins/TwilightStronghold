--[[
    InteractionClient.client.lua
    Handles client-side interactions and sends requests to the server.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Wait for Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GatherEvent = Remotes:WaitForChild("GatherResource")

local MinigameController = require(script.Parent.MinigameController)

print("[InteractionClient] Initialized. Listening for prompts.")
MinigameController.Init()

-- Toast Notification System
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "NotificationUI"
notifGui.ResetOnSpawn = false
notifGui.Parent = player:WaitForChild("PlayerGui")

local function showNotification(text)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0, 200, 0, 40)
    label.Position = UDim2.new(0.5, -100, 0.7, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.Parent = notifGui

    -- Animate: Float up and fade out
    local info = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {
        Position = UDim2.new(0.5, -100, 0.5, 0),
        TextTransparency = 1,
        TextStrokeTransparency = 1
    }

    local tween = TweenService:Create(label, info, goal)
    tween:Play()
    tween.Completed:Connect(function()
        label:Destroy()
    end)
end

-- Listen for Gathering Feedback
GatherEvent.OnClientEvent:Connect(function(item, qty)
    local msg = string.format("+%d %s", qty, item)
    showNotification(msg)
    print(string.format("[InteractionClient] Received: %s x%d", item, qty))
end)

ProximityPromptService.PromptTriggered:Connect(function(promptObject, triggerPlayer)
    if triggerPlayer ~= player then return end
    
    if promptObject.Name == "Gather" then
        print("[InteractionClient] Starting Minigame...")
        
        -- Start Minigame
        MinigameController.Start(function()
            print("[InteractionClient] Minigame Success! Gathering...")
            local resourceNode = promptObject.Parent
            GatherEvent:FireServer(resourceNode)
        end)
    end
end)
