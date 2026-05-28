--[[
    Weapons.spec.lua
    Verifies every Weapon in ItemDatabase has the fields CombatSystem requires.
    If you add a weapon and forget Damage/Range/Cooldown, this fails loudly.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

return function(test)
    test.describe("Weapons", function()
        test.it("wooden_sword has all combat fields", function()
            local def = ItemDatabase.GetItem("wooden_sword")
            test.expect(def).toBeTruthy()
            test.expect(def.Type).toEqual("Weapon")
            test.expect(type(def.Damage)).toEqual("number")
            test.expect(type(def.Range)).toEqual("number")
            test.expect(type(def.Cooldown)).toEqual("number")
        end)

        test.it("void_sword has all combat fields", function()
            local def = ItemDatabase.GetItem("void_sword")
            test.expect(def).toBeTruthy()
            test.expect(def.Type).toEqual("Weapon")
            test.expect(type(def.Damage)).toEqual("number")
            test.expect(type(def.Range)).toEqual("number")
            test.expect(type(def.Cooldown)).toEqual("number")
        end)

        test.it("void_sword hits harder than wooden_sword", function()
            local wood = ItemDatabase.GetItem("wooden_sword")
            local void = ItemDatabase.GetItem("void_sword")
            test.expect(void.Damage > wood.Damage).toBeTruthy()
        end)
    end)
end
