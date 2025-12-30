--[[
    DayNightCycle.lua
    Manages the core game loop for Survival Mode.
    Broadcasting Phase Changes: Day (Build) <-> Night (Combat).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local DayNightCycle = {}

-- Events
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PhaseChanged = Instance.new("RemoteEvent", Remotes)
PhaseChanged.Name = "PhaseChanged"

-- State
DayNightCycle.Phase = "Day" -- "Day" or "Night"
DayNightCycle.DayCount = 1
DayNightCycle.TimeRemaining = 0

-- Config
local DAY_LENGTH = 60 -- Seconds (Short for MVP, usually 300)
local NIGHT_LENGTH = 30 -- Seconds (Short for MVP, usually 120)

function DayNightCycle.Init()
    print("[DayNightCycle] Initialized.")
    DayNightCycle.StartDay()
    
    task.spawn(function()
        while true do
            task.wait(1)
            DayNightCycle.Tick()
        end
    end)
end

function DayNightCycle.Tick()
    DayNightCycle.TimeRemaining = DayNightCycle.TimeRemaining - 1
    
    if DayNightCycle.TimeRemaining <= 0 then
        if DayNightCycle.Phase == "Day" then
            DayNightCycle.StartNight()
        else
            DayNightCycle.StartDay()
        end
    end
end

function DayNightCycle.StartDay()
    DayNightCycle.Phase = "Day"
    DayNightCycle.DayCount = DayNightCycle.DayCount + 1
    DayNightCycle.TimeRemaining = DAY_LENGTH
    
    -- Visuals
    Lighting.ClockTime = 14 -- 2 PM
    print(string.format("[DayNightCycle] Day %d Started. Build Phase.", DayNightCycle.DayCount))
    
    PhaseChanged:FireAllClients("Day", DayNightCycle.DayCount, DayNightCycle.TimeRemaining)
end

function DayNightCycle.StartNight()
    DayNightCycle.Phase = "Night"
    DayNightCycle.TimeRemaining = NIGHT_LENGTH
    
    -- Visuals
    Lighting.ClockTime = 0 -- Midnight
    print(string.format("[DayNightCycle] Night %d Started. Combat Phase!", DayNightCycle.DayCount))
    
    PhaseChanged:FireAllClients("Night", DayNightCycle.DayCount, DayNightCycle.TimeRemaining)
    
    -- Notify WaveManager (In a real architecture, we'd use a BindableEvent or direct require)
    local WaveManager = require(script.Parent.WaveManager)
    WaveManager.StartWave(DayNightCycle.DayCount)
end

return DayNightCycle
