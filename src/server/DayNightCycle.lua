--[[
    DayNightCycle.lua
    Manages the core game loop for Survival Mode.
    Broadcasting Phase Changes: Day (Build) <-> Night (Combat).
    Fires Day150Reached once when DayCount hits GameConfig.MILESTONE_NIGHT.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local DayNightCycle = {}

-- Events
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PhaseChanged = Instance.new("RemoteEvent")
PhaseChanged.Name = "PhaseChanged"
PhaseChanged.Parent = Remotes

-- Fires once when DayCount reaches MILESTONE_NIGHT. Run does not end —
-- the cycle continues in endless mode (see docs/VISION.md §1.4).
local Day150Reached = Instance.new("RemoteEvent")
Day150Reached.Name = "Day150Reached"
Day150Reached.Parent = Remotes

-- State
DayNightCycle.Phase = "Day" -- "Day" or "Night"
-- DayCount starts at 0 because StartDay() increments before announcing.
-- Initial StartDay() call from Init() takes us to Day 1, not Day 2.
DayNightCycle.DayCount = 0
DayNightCycle.TimeRemaining = 0
DayNightCycle.MilestoneFired = false -- prevent re-firing on subsequent days

-- Config
local DAY_LENGTH = 300 -- Seconds (Production)
local NIGHT_LENGTH = 120 -- Seconds (Production Value)

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

    -- Day 150 milestone: fire once, then continue in endless mode.
    if not DayNightCycle.MilestoneFired and DayNightCycle.DayCount >= GameConfig.MILESTONE_NIGHT then
        DayNightCycle.MilestoneFired = true
        print(
            string.format("[DayNightCycle] 🏆 Day %d milestone reached! Endless mode active.", DayNightCycle.DayCount)
        )
        Day150Reached:FireAllClients(DayNightCycle.DayCount)
    end
end

function DayNightCycle.StartNight()
    DayNightCycle.Phase = "Night"
    DayNightCycle.TimeRemaining = NIGHT_LENGTH

    -- Visuals
    Lighting.ClockTime = 0 -- Midnight
    print(string.format("[DayNightCycle] Night %d Started. Combat Phase!", DayNightCycle.DayCount))

    PhaseChanged:FireAllClients("Night", DayNightCycle.DayCount, DayNightCycle.TimeRemaining)

    local WaveManager = require(script.Parent.WaveManager)
    WaveManager.StartWave(DayNightCycle.DayCount)
end

return DayNightCycle
