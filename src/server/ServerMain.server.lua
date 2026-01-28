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

-- Conditional Loading based on Mode (Lobby vs Survival)
local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

-- Determine if we are in Survival Mode
-- We check if the PlaceId matches the configured Survival Zone ID,
-- OR if the debug flag IS_SURVIVAL_MODE is set (for testing in Studio/Lobby).
local isSurvival = (game.PlaceId == GameConfig.PLACE_IDS.SurvivalZone) or GameConfig.IS_SURVIVAL_MODE

if isSurvival then
    print("[Server] Starting Survival Mode Modules...")
    require(script.Parent.DayNightCycle).Init()
    require(script.Parent.WaveManager).Init()
    require(script.Parent.BuildingSystem).Init()
else
    print("[Server] Running Lobby Mode.")
end

print("[Server] All systems initialized.")
