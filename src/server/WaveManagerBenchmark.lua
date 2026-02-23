local function benchmark()
    local iterations = 100000
    local position = Vector3.new(0, 0, 0)
    local targetPos = Vector3.new(10, 10, 10)

    print(string.format("Running vector math benchmark with %d iterations...", iterations))

    -- Baseline: Magnitude (sqrt)
    local startBaseline = os.clock()
    for i = 1, iterations do
        local dist = (targetPos - position).Magnitude
        if dist < 50 then
            -- do something
        end
    end
    local endBaseline = os.clock()
    local baselineTime = endBaseline - startBaseline

    -- Optimization: Squared Magnitude (dot)
    local startOpt = os.clock()
    local thresholdSq = 50 * 50
    for i = 1, iterations do
        local offset = targetPos - position
        local distSq = offset:Dot(offset)
        if distSq < thresholdSq then
            -- do something
        end
    end
    local endOpt = os.clock()
    local optTime = endOpt - startOpt

    print(string.format("Baseline (Magnitude): %.6f seconds", baselineTime))
    print(string.format("Optimization (Dot): %.6f seconds", optTime))
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
