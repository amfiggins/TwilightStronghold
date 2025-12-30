--[[
    ServerMain.server.lua
    The main entry point for the server. Initializes all game systems.
]]

local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

print("[Server] Starting Twilight Stronghold Server...")

-- Initialize Systems
PlayerDataHandler.Init()
require(script.Parent.ResourceManager).Init()
require(script.Parent.LoadoutManager).Init()
require(script.Parent.MatchmakingService).Init()

require(script.Parent.MatchmakingService).Init()

-- Conditional Loading based on Mode (Lobby vs Survival)
-- For this MVP, we use a simple flag in GameConfig to toggle for testing.
-- In production, we would check game.PlaceId.
local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

if GameConfig.IS_SURVIVAL_MODE then
    print("[Server] Starting Survival Mode Modules...")
    require(script.Parent.DayNightCycle).Init()
    require(script.Parent.WaveManager).Init()
    require(script.Parent.BuildingSystem).Init()
else
    print("[Server] Running Lobby Mode.")
end

print("[Server] All systems initialized.")
