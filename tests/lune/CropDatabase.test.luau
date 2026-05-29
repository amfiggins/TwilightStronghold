--!strict
--[[
    CropDatabase.test.luau

    Verifies the CropDatabase ↔ ItemDatabase cross-references. A new crop
    definition without matching seed/crop ItemDatabase entries (or vice
    versa) will fail these tests, preventing half-wired entries from
    landing on main.
]]

local CropDatabase = require("../../src/shared/CropDatabase")
local ItemDatabase = require("../../src/shared/ItemDatabase")

return function(test: any)
    test.describe("CropDatabase shape", function()
        test.it("GetCrop returns nil for unknown keys", function()
            test.expect(CropDatabase.GetCrop("nope_does_not_exist")).toEqual(nil)
        end)

        test.it("GetAll returns at least three crops", function()
            local crops = CropDatabase.GetAll()
            local count = 0
            for _ in pairs(crops) do
                count = count + 1
            end
            test.expect(count >= 3).toBeTruthy()
        end)
    end)

    test.describe("Every crop has the required fields", function()
        for cropKey, def in pairs(CropDatabase.GetAll()) do
            test.it(cropKey .. " is well-formed", function()
                test.expect(type(def.SeedItemId)).toEqual("string")
                test.expect(type(def.CropItemId)).toEqual("string")
                test.expect(type(def.GrowthSeconds)).toEqual("number")
                test.expect(def.GrowthSeconds > 0).toBeTruthy()
                test.expect(type(def.WaterRequirement)).toEqual("number")
                test.expect(def.WaterRequirement >= 0).toBeTruthy()
                test.expect(type(def.Yield)).toEqual("table")
                test.expect(type(def.Yield.Min)).toEqual("number")
                test.expect(type(def.Yield.Max)).toEqual("number")
                test.expect(def.Yield.Max >= def.Yield.Min).toBeTruthy()
                test.expect(type(def.Stages)).toEqual("table")
                test.expect(#def.Stages >= 2).toBeTruthy()
                -- The last stage must be "ready" so PlotManager can detect
                -- harvest-ability without per-crop logic.
                test.expect(def.Stages[#def.Stages]).toEqual("ready")
            end)
        end
    end)

    test.describe("CropDatabase ↔ ItemDatabase cross-references", function()
        for cropKey, def in pairs(CropDatabase.GetAll()) do
            test.it(cropKey .. ".SeedItemId resolves to a Type=Seed item", function()
                local seedItem = ItemDatabase.GetItem(def.SeedItemId)
                test.expect(seedItem).toBeTruthy()
                test.expect(seedItem.Type).toEqual("Seed")
                -- The seed's SeedFor must round-trip back to this crop key.
                test.expect(seedItem.SeedFor).toEqual(cropKey)
            end)

            test.it(cropKey .. ".CropItemId resolves to a real item", function()
                local cropItem = ItemDatabase.GetItem(def.CropItemId)
                test.expect(cropItem).toBeTruthy()
            end)
        end
    end)

    test.describe("Reverse lookup", function()
        test.it("GetCropForSeed returns the right crop", function()
            local crop = CropDatabase.GetCropForSeed("wheat_seed")
            test.expect(crop).toBeTruthy()
            test.expect(crop.CropItemId).toEqual("wheat")
        end)

        test.it("GetCropForSeed returns nil for non-seed items", function()
            test.expect(CropDatabase.GetCropForSeed("wood_log")).toEqual(nil)
            test.expect(CropDatabase.GetCropForSeed("nope")).toEqual(nil)
        end)
    end)

    test.describe("Farming tools exist in ItemDatabase", function()
        for _, toolId in ipairs({ "hoe", "watering_can", "fertilizer" }) do
            test.it(toolId .. " is defined", function()
                local def = ItemDatabase.GetItem(toolId)
                test.expect(def).toBeTruthy()
                -- Tools are Type "Tool", fertilizer is "Material" — both fine.
                local validTypes = { Tool = true, Material = true }
                test.expect(validTypes[def.Type] or false).toBeTruthy()
            end)
        end
    end)
end
