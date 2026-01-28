local function benchmark()
    local iterations = 10000

    print(string.format("Running benchmark with %d iterations...", iterations))

    -- Baseline: Instance.new and property setting
    local startBaseline = os.clock()
    for i = 1, iterations do
        local part = Instance.new("Part")
        part.Name = "Enemy"
        part.BrickColor = BrickColor.new("Really red")
        part.Anchored = true
        part.Position = Vector3.new(0, 5, 0)
        part:Destroy() -- Cleanup
    end
    local endBaseline = os.clock()
    local baselineTime = endBaseline - startBaseline

    -- Optimization: Clone
    local template = Instance.new("Part")
    template.Name = "Enemy"
    template.BrickColor = BrickColor.new("Really red")
    template.Anchored = true

    local startOpt = os.clock()
    for i = 1, iterations do
        local part = template:Clone()
        part.Position = Vector3.new(0, 5, 0)
        part:Destroy() -- Cleanup
    end
    local endOpt = os.clock()
    local optTime = endOpt - startOpt

    print(string.format("Baseline (Instance.new): %.4f seconds", baselineTime))
    print(string.format("Optimization (Clone): %.4f seconds", optTime))
    print(string.format("Improvement: %.2f%%", ((baselineTime - optTime) / baselineTime) * 100))
end

-- Check if we are in a Roblox environment to run
if game then
    task.spawn(benchmark)
end

return benchmark
