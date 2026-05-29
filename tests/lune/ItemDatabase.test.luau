--!strict
local ItemDatabase = require("../../src/shared/ItemDatabase")

return function(test: any)
    test.describe("ItemDatabase", function()
        test.it("returns nil for unknown items", function()
            test.expect(ItemDatabase.GetItem("nope_does_not_exist")).toEqual(nil)
        end)

        test.it("returns the wooden_rod definition", function()
            local item = ItemDatabase.GetItem("wooden_rod")
            test.expect(item).toBeTruthy()
            test.expect(item.Type).toEqual("Tool")
            test.expect(item.Stackable).toEqual(false)
        end)

        test.it("declares all bag types with a Capacity", function()
            for _, bagId in ipairs({ "starter_bag", "leather_bag", "reinforced_bag" }) do
                local item = ItemDatabase.GetItem(bagId)
                test.expect(item).toBeTruthy()
                test.expect(item.Type).toEqual("Bag")
                test.expect(type(item.Capacity)).toEqual("number")
            end
        end)
    end)
end
