--[[
    InventoryBenchmark.lua
    Measures performance of removing items from a large inventory.
    Usage: Run in Roblox Studio command bar or server script.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local function runBenchmark()
    print("--- Inventory Benchmark: RemoveItem Performance ---")

    -- Mock Player
    local mockPlayer = {
        UserId = 12345678,
        Name = "BenchmarkUser"
    }

    -- Setup Data
    -- Force load
    local data = {
        Stats = { Rubies=0, Diamonds=0, Level=1, XP=0 },
        Inventory = {},
        Loadout = { Weapon=nil, BaseKit=nil },
        CodesRedeemed = {}
    }

    -- Access private sessionData via brute force if possible, or just call AddItem many times
    -- Since we can't access locals easily, we'll simulate OnPlayerAdded
    -- But OnPlayerAdded calls GetAsync. We don't want real DataStore calls.

    -- We'll manually inject data into sessionData using debug library or just assume we can
    -- modify the module to expose internal state for testing? No, that's invasive.

    -- Plan: Use AddItem to populate. It might be slow but it works.
    -- Wait, AddItem uses sessionData. We need sessionData to be populated.
    -- OnPlayerAdded populates it. But it requires DataStore.

    -- Alternative: We can require the module and modify the 'sessionData' upvalue using debug.getupvalue if available?
    -- No, Roblox security prevents that usually.

    -- Maybe we can just mock the DataStoreService?
    -- Hard to do without a framework.

    -- Actually, let's just create a local version of the logic to test purely the algorithm.
    -- This benchmark script will contain the *logic* of the old vs new implementation for comparison.

    local ITEM_COUNT = 10000
    local REMOVE_COUNT = 1000

    -- Setup specific test data
    local inventory = {}
    local lookup = {}

    for i = 1, ITEM_COUNT do
        local id = "Item_" .. i
        table.insert(inventory, { ItemId = id, Qty = 1 })
        lookup[id] = i
    end

    print(string.format("Initial Inventory Size: %d", #inventory))

    -- Baseline: Standard table.remove + Rebuild Lookup
    local startTime = os.clock()

    for i = 1, REMOVE_COUNT do
        -- Remove random item (simulate worst case: index 1)
        local removeIndex = 1
        local item = inventory[removeIndex]

        table.remove(inventory, removeIndex)

        -- Rebuild Lookup (Old Way)
        lookup = {}
        for idx, slot in ipairs(inventory) do
            if not lookup[slot.ItemId] then
                lookup[slot.ItemId] = idx
            end
        end
    end

    local duration = os.clock() - startTime
    print(string.format("Baseline (O(N) Shift + Rebuild): %.4f seconds for %d removals", duration, REMOVE_COUNT))
    print(string.format("Average per removal: %.6f seconds", duration / REMOVE_COUNT))


    -- Reset Data for Optimization Test
    inventory = {}
    lookup = {}
    for i = 1, ITEM_COUNT do
        local id = "Item_" .. i
        table.insert(inventory, { ItemId = id, Qty = 1 })
        lookup[id] = i
    end

    -- Optimized: Swap-Remove + Update Lookup
    startTime = os.clock()

    for i = 1, REMOVE_COUNT do
        local removeIndex = 1
        local itemToRemove = inventory[removeIndex]
        local lastIndex = #inventory
        local lastItem = inventory[lastIndex]

        if removeIndex == lastIndex then
            table.remove(inventory, lastIndex)
            lookup[itemToRemove.ItemId] = nil
        else
            -- Swap
            inventory[removeIndex] = lastItem
            table.remove(inventory, lastIndex)

            -- Update Lookup
            lookup[lastItem.ItemId] = removeIndex
            lookup[itemToRemove.ItemId] = nil
        end
    end

    local durationOpt = os.clock() - startTime
    print(string.format("Optimized (O(1) Swap): %.4f seconds for %d removals", durationOpt, REMOVE_COUNT))
    print(string.format("Average per removal: %.6f seconds", durationOpt / REMOVE_COUNT))

    local speedup = duration / durationOpt
    print(string.format("Speedup: %.2fx", speedup))
end

return runBenchmark
