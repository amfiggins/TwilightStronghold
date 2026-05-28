--[[
    Vitals.spec.lua
    Verifies every Food/Drink item in ItemDatabase has the fields
    VitalsSystem requires. Catches future items that forget HungerRestore
    or ThirstRestore.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

return function(test)
    test.describe("Food items", function()
        test.it("raw_fish is Type Food with HungerRestore", function()
            local def = ItemDatabase.GetItem("raw_fish")
            test.expect(def).toBeTruthy()
            test.expect(def.Type).toEqual("Food")
            test.expect(type(def.HungerRestore)).toEqual("number")
        end)

        test.it("cooked_fish restores more hunger than raw_fish", function()
            local raw = ItemDatabase.GetItem("raw_fish")
            local cooked = ItemDatabase.GetItem("cooked_fish")
            test.expect(cooked.HungerRestore > raw.HungerRestore).toBeTruthy()
        end)

        test.it("berries restore both hunger and thirst", function()
            local def = ItemDatabase.GetItem("berries")
            test.expect(def).toBeTruthy()
            test.expect(type(def.HungerRestore)).toEqual("number")
            test.expect(type(def.ThirstRestore)).toEqual("number")
        end)
    end)

    test.describe("Drink items", function()
        test.it("water_flask is Type Drink with ThirstRestore", function()
            local def = ItemDatabase.GetItem("water_flask")
            test.expect(def).toBeTruthy()
            test.expect(def.Type).toEqual("Drink")
            test.expect(type(def.ThirstRestore)).toEqual("number")
        end)
    end)
end
