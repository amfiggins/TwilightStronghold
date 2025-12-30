--[[
    PortalController.client.lua
    Handles interactions with the "Survival Portal" to join the Matchmaking Queue.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinQueueEvent = Remotes:WaitForChild("JoinQueue")

print("[PortalController] Initialized. Listening for Portal prompts.")

ProximityPromptService.PromptTriggered:Connect(function(promptObject, triggerPlayer)
    if triggerPlayer ~= player then return end
    
    if promptObject.Name == "EnterSurvival" then
        print("[PortalController] Requesting to join queue...")
        JoinQueueEvent:FireServer()
        
        -- Optional: Show Queue UI
        -- QueueUI.Show()
    end
end)
