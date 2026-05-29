--[[
    MatchmakingService.lua
    Handles player queues and teleports them to the Survival Session place.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local MatchmakingService = {}
local queue = {} -- List of players waiting
local queueSet = {} -- O(1) lookup for queue membership

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinQueueEvent = Instance.new("RemoteEvent")
JoinQueueEvent.Name = "JoinQueue"
JoinQueueEvent.Parent = Remotes

local QueueUpdateEvent = Instance.new("RemoteEvent")
QueueUpdateEvent.Name = "QueueUpdate"
QueueUpdateEvent.Parent = Remotes

-- Constants
local REQUIRED_PLAYERS = GameConfig.MAX_SESSION_PLAYERS -- Ensure full squads are formed

function MatchmakingService.Init()
    print("[MatchmakingService] Initialized.")

    -- Listen for Client Requests
    JoinQueueEvent.OnServerEvent:Connect(function(player)
        MatchmakingService.JoinQueue(player)
    end)

    -- Remove players from queue when they disconnect
    Players.PlayerRemoving:Connect(function(player)
        MatchmakingService.LeaveQueue(player)
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
    if queueSet[player] then
        return
    end

    table.insert(queue, player)
    queueSet[player] = true
    print(string.format("[Matchmaking] %s joined queue. (%d/%d)", player.Name, #queue, REQUIRED_PLAYERS))

    -- Try to process queue immediately
    task.spawn(MatchmakingService.ProcessQueue)

    -- Optional: Fire client event to update UI
    QueueUpdateEvent:FireClient(player, true, #queue, REQUIRED_PLAYERS)
end

function MatchmakingService.LeaveQueue(player)
    if not queueSet[player] then
        return
    end
    local idx = table.find(queue, player)
    if idx then
        table.remove(queue, idx)
        queueSet[player] = nil
        print(string.format("[Matchmaking] %s left queue.", player.Name))
        QueueUpdateEvent:FireClient(player, false, #queue, REQUIRED_PLAYERS)
    end
end

function MatchmakingService.ProcessQueue()
    while #queue >= REQUIRED_PLAYERS do
        print("[Matchmaking] Found match! Teleporting...")

        -- Extract the squad
        local squad = table.create(REQUIRED_PLAYERS)
        table.move(queue, 1, REQUIRED_PLAYERS, 1, squad)

        -- Remove from queueSet
        for _, p in ipairs(squad) do
            queueSet[p] = nil
        end

        -- Batch remove from queue (shift remaining players down)
        local newSize = #queue - REQUIRED_PLAYERS
        if newSize > 0 then
            table.move(queue, REQUIRED_PLAYERS + 1, #queue, 1)
        end

        -- Clear the old tail elements
        for i = #queue, newSize + 1, -1 do
            queue[i] = nil
        end

        task.spawn(function()
            -- Prepare Teleport Options (Pass Data!)
            local teleportOptions = Instance.new("TeleportOptions")
            local teleportData = {
                MatchId = game.HttpService:GenerateGUID(false),
                SquadNames = {},
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
                    -- Prevent re-queuing disconnected ghost players (DoS fix)
                    if p and p.Parent then
                        table.insert(queue, p)
                        queueSet[p] = true
                    end
                end
            end
        end)
    end
end

-- Handle Teleport Failures
TeleportService.TeleportInitFailed:Connect(function(player, _result, errorMessage)
    warn(string.format("[Matchmaking] Teleport failed for %s: %s", player.Name, errorMessage))
end)

return MatchmakingService
