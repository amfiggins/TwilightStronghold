--[[
    MatchmakingService.lua
    Handles player queues and teleports them to the Survival Session place.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local MatchmakingService = {}
local queue = {} -- List of players waiting

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinQueueEvent = Instance.new("RemoteEvent", Remotes)
JoinQueueEvent.Name = "JoinQueue"

local QueueUpdateEvent = Instance.new("RemoteEvent", Remotes)
QueueUpdateEvent.Name = "QueueUpdate"

-- Constants
local REQUIRED_PLAYERS = 1 -- Set to 1 for testing, normally GameConfig.MAX_SESSION_PLAYERS

function MatchmakingService.Init()
    print("[MatchmakingService] Initialized.")
    
    -- Listen for Client Requests
    JoinQueueEvent.OnServerEvent:Connect(function(player)
        MatchmakingService.JoinQueue(player)
    end)
    
    -- Loop to check queue
    task.spawn(function()
        while true do
            task.wait(5)
            MatchmakingService.ProcessQueue()
        end
    end)
end

function MatchmakingService.JoinQueue(player)
    if table.find(queue, player) then return end
    
    table.insert(queue, player)
    print(string.format("[Matchmaking] %s joined queue. (%d/%d)", player.Name, #queue, REQUIRED_PLAYERS))
    
    -- Try to process queue immediately
    task.spawn(MatchmakingService.ProcessQueue)

    -- Optional: Fire client event to update UI
    QueueUpdateEvent:FireClient(player, true, #queue, REQUIRED_PLAYERS)
end

function MatchmakingService.LeaveQueue(player)
    local idx = table.find(queue, player)
    if idx then
        table.remove(queue, idx)
        print(string.format("[Matchmaking] %s left queue.", player.Name))
        QueueUpdateEvent:FireClient(player, false, #queue, REQUIRED_PLAYERS)
    end
end

function MatchmakingService.ProcessQueue()
    while #queue >= REQUIRED_PLAYERS do
        print("[Matchmaking] Found match! Teleporting...")
        
        -- Extract the squad
        local squad = {}
        for i = 1, REQUIRED_PLAYERS do
            table.insert(squad, table.remove(queue, 1))
        end
        
        task.spawn(function()
            -- Prepare Teleport Options (Pass Data!)
            local teleportOptions = Instance.new("TeleportOptions")
            local teleportData = {
                MatchId = game.HttpService:GenerateGUID(false),
                SquadNames = {}
            }

            -- Collect Squad Info
            for _, p in ipairs(squad) do
                table.insert(teleportData.SquadNames, p.Name)
                -- Note: We rely on DataStores for main data, but we can pass Session ID here
            end

            teleportOptions:SetTeleportData(teleportData)

            -- Teleport
            local success, err = pcall(function()
                TeleportService:TeleportAsync(GameConfig.PLACE_IDS.SurvivalZone, squad, teleportOptions)
            end)

            if not success then
                warn("[Matchmaking] Teleport Failed: " .. tostring(err))
                -- Re-queue players (simplified logic)
                for _, p in ipairs(squad) do
                    table.insert(queue, p)
                end
            end
        end)
    end
end

-- Handle Teleport Failures
TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
    warn(string.format("[Matchmaking] Teleport failed for %s: %s", player.Name, errorMessage))
end)

return MatchmakingService
