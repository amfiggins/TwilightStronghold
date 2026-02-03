local function benchmark()
    local iterations = 100 -- How many times to run the full queue drain
    local queueSize = 1000
    local squadSize = 4

    print(string.format("Running queue benchmark with %d iterations, queue size %d, squad size %d...", iterations, queueSize, squadSize))

    -- Baseline: Repeated table.remove
    local startBaseline = os.clock()
    for _ = 1, iterations do
        local queue = {}
        for i = 1, queueSize do queue[i] = i end -- Populate

        while #queue >= squadSize do
            local squad = {}
            for i = 1, squadSize do
                table.insert(squad, table.remove(queue, 1))
            end
        end
    end
    local endBaseline = os.clock()
    local baselineTime = endBaseline - startBaseline

    -- Optimization: table.move
    local startOpt = os.clock()
    for _ = 1, iterations do
        local queue = {}
        for i = 1, queueSize do queue[i] = i end -- Populate

        while #queue >= squadSize do
            local squad = table.create(squadSize)
            table.move(queue, 1, squadSize, 1, squad)

            -- Shift
            local newSize = #queue - squadSize
            if newSize > 0 then
                table.move(queue, squadSize + 1, #queue, 1)
            end

            -- Clear tail
            for i = #queue, newSize + 1, -1 do
                queue[i] = nil
            end
        end
    end
    local endOpt = os.clock()
    local optTime = endOpt - startOpt

    print(string.format("Baseline (table.remove): %.4f seconds", baselineTime))
    print(string.format("Optimization (table.move): %.4f seconds", optTime))
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
