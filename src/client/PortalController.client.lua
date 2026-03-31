--[[
    PortalController.client.lua
    Handles interactions with the "Survival Portal" to join the Matchmaking Queue.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Check Mode
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local isSurvival = (game.PlaceId == GameConfig.PLACE_IDS.SurvivalZone) or GameConfig.IS_SURVIVAL_MODE
if isSurvival then
    print("[PortalController] Survival Mode detected. Disabling Portal Controller.")
    return
end

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinQueueEvent = Remotes:WaitForChild("JoinQueue")
local QueueUpdateEvent = Remotes:WaitForChild("QueueUpdate")

print("[PortalController] Initialized. Listening for Portal prompts.")

-- Toast Notification System for Queue Updates
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "QueueNotificationUI"
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

QueueUpdateEvent.OnClientEvent:Connect(function(joined, queueSize, requiredPlayers)
    local status = joined and "Joined" or "Left"
    print(string.format("[Client] Queue Status: %s. Count: %d/%d", status, queueSize, requiredPlayers))
    showNotification(string.format("Queue %s: %d/%d", status, queueSize, requiredPlayers))
end)

ProximityPromptService.PromptTriggered:Connect(function(promptObject, triggerPlayer)
    if triggerPlayer ~= player then return end
    
    if promptObject.Name == "EnterSurvival" then
        print("[PortalController] Requesting to join queue...")
        JoinQueueEvent:FireServer()
        
        -- Optional: Show Queue UI
        -- QueueUI.Show()
    end
end)
