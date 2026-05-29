--!strict
--[[
    BeastDatabase.test.luau

    Verifies BeastDatabase entries are well-formed and that the per-biome
    lookup works. New beast definitions that forget required fields will
    fail these tests.
]]

local BeastDatabase = require("../../src/shared/BeastDatabase")

return function(test: any)
    test.describe("BeastDatabase shape", function()
        test.it("GetBeast returns nil for unknown keys", function()
            test.expect(BeastDatabase.GetBeast("not_a_real_beast")).toEqual(nil)
        end)

        test.it("Wendigo, Yeti, and Djinn Stalker are all defined", function()
            test.expect(BeastDatabase.GetBeast("wendigo")).toBeTruthy()
            test.expect(BeastDatabase.GetBeast("yeti")).toBeTruthy()
            test.expect(BeastDatabase.GetBeast("djinn_stalker")).toBeTruthy()
        end)
    end)

    test.describe("Every beast has the required fields", function()
        for key, def in pairs(BeastDatabase.GetAll()) do
            test.it(key .. " is well-formed", function()
                test.expect(type(def.Name)).toEqual("string")
                test.expect(type(def.Biome)).toEqual("string")
                test.expect(type(def.ModelHeight)).toEqual("number")
                test.expect(def.ModelHeight > 0).toBeTruthy()
                test.expect(type(def.ModelRGB)).toEqual("table")
                test.expect(#def.ModelRGB).toEqual(3)
                test.expect(type(def.WalkSpeed)).toEqual("number")
                test.expect(type(def.ChaseSpeed)).toEqual("number")
                test.expect(def.ChaseSpeed > def.WalkSpeed).toBeTruthy()
                test.expect(type(def.StalkRangeMin)).toEqual("number")
                test.expect(type(def.StalkRangeMax)).toEqual("number")
                test.expect(def.StalkRangeMax > def.StalkRangeMin).toBeTruthy()
                test.expect(type(def.GlimpseRange)).toEqual("number")
                test.expect(def.GlimpseRange < def.StalkRangeMin).toBeTruthy()
                test.expect(type(def.LightRetreat)).toEqual("number")
                test.expect(type(def.JumpScareDamage)).toEqual("number")
                test.expect(def.JumpScareDamage > 0).toBeTruthy()
            end)
        end
    end)

    test.describe("Biome lookup", function()
        test.it("Wendigo is the Forest Kingdom beast", function()
            local def = BeastDatabase.GetBeastForBiome("ForestKingdom")
            test.expect(def).toBeTruthy()
            test.expect(def.Name).toEqual("Wendigo")
        end)

        test.it("Unknown biomes return nil", function()
            test.expect(BeastDatabase.GetBeastForBiome("NoSuchBiome")).toEqual(nil)
        end)

        test.it("Every biome has at most one beast", function()
            local seenBiomes = {}
            for _, def in pairs(BeastDatabase.GetAll()) do
                test.expect(seenBiomes[def.Biome]).toBeFalsy()
                seenBiomes[def.Biome] = true
            end
        end)
    end)
end
