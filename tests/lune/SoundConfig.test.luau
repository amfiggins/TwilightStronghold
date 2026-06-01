--!strict
--[[
    SoundConfig.test.luau

    Verifies that every sound key referenced by client modules exists in
    SoundConfig, and that every entry is well-formed (real-looking
    rbxassetid URI, a Volume in [0, 1]).
]]

local SoundConfig = require("../../src/shared/SoundConfig")

-- Keys actually referenced by BeastAudioClient. If a client adds a new
-- ref, mirror it here so missing entries fail loudly.
local REQUIRED_BEAST_KEYS = {
    "Beast.Footstep",
    "Beast.BranchSnap",
    "Beast.Breathing",
    "Beast.Growl",
    "Beast.AmbientHowl",
    "Beast.ChaseMusic",
}

return function(test: any)
    test.describe("SoundConfig shape", function()
        test.it("Get returns nil for unknown keys", function()
            test.expect(SoundConfig.Get("not_a_real_sound")).toEqual(nil)
        end)

        for _, key in ipairs(REQUIRED_BEAST_KEYS) do
            test.it(key .. " exists", function()
                local def = SoundConfig.Get(key)
                test.expect(def).toBeTruthy()
            end)
        end
    end)

    test.describe("Every entry is well-formed", function()
        for key, def in pairs(SoundConfig.GetAll()) do
            test.it(key .. " has a valid AssetId and Volume", function()
                test.expect(type(def.AssetId)).toEqual("string")
                test.expect(def.AssetId:sub(1, 13)).toEqual("rbxassetid://")
                test.expect(type(def.Volume)).toEqual("number")
                test.expect(def.Volume >= 0 and def.Volume <= 1).toBeTruthy()
            end)
        end
    end)
end
