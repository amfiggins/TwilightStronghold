--[[
    InteractionClient.client.lua
    Handles client-side interactions and sends requests to the server.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Wait for Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GatherEvent = Remotes:WaitForChild("GatherResource")

local MinigameController = require(script.Parent.MinigameController)

print("[InteractionClient] Initialized. Listening for prompts.")
MinigameController.Init()

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
