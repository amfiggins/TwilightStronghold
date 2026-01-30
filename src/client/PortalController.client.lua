--[[
    PortalController.client.lua
    Handles interactions with the "Survival Portal" to join the Matchmaking Queue.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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

QueueUpdateEvent.OnClientEvent:Connect(function(joined, queueSize, requiredPlayers)
    local status = joined and "Joined" or "Left"
    print(string.format("[Client] Queue Status: %s. Count: %d/%d", status, queueSize, requiredPlayers))
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
