--[[
    InventoryBenchmark.lua
    Benchmarks the performance of standard table.remove (O(N)) vs.
    the Swap-Remove approach (O(1)) for large inventory tables.
    Run this in a Roblox environment to see results.
]]

local function benchmark()
    local iterations = 1000
    local inventorySize = 1000 -- Large inventory to make O(N) shift noticeable

    print(string.format("Running Inventory Benchmark with %d iterations, size %d...", iterations, inventorySize))

    -- 1. Baseline: table.remove (O(N))
    local baselineStart = os.clock()
    for _ = 1, iterations do
        -- Setup
        local inventory = {}
        for i = 1, inventorySize do
            inventory[i] = { ItemId = "item_" .. i, Qty = 1 }
        end

        -- Remove from middle
        table.remove(inventory, math.floor(inventorySize / 2))
    end
    local baselineTime = os.clock() - baselineStart

    -- 2. Optimized: Swap-Remove (O(1))
    local optStart = os.clock()
    for _ = 1, iterations do
        -- Setup
        local inventory = {}
        for i = 1, inventorySize do
            inventory[i] = { ItemId = "item_" .. i, Qty = 1 }
        end

        -- Remove from middle using Swap-Remove
        local slotIndex = math.floor(inventorySize / 2)
        local lastIndex = #inventory

        if slotIndex == lastIndex then
            inventory[lastIndex] = nil
        else
            inventory[slotIndex] = inventory[lastIndex]
            inventory[lastIndex] = nil
        end
    end
    local optTime = os.clock() - optStart

    print(string.format("Baseline (table.remove O(N)): %.4f seconds", baselineTime))
    print(string.format("Optimized (Swap-Remove O(1)): %.4f seconds", optTime))

    local improvement = 0
    if baselineTime > 0 then
        improvement = ((baselineTime - optTime) / baselineTime) * 100
    end
    print(string.format("Improvement: %.2f%%", improvement))
end

if game then
    task.spawn(benchmark)
end

return benchmark
