local function benchmark()
    local iterations = 10000 -- How many structures to create
    print(string.format("Running building benchmark with %d iterations...", iterations))

    -- Baseline: Instance.new
    local startBaseline = os.clock()
    for _ = 1, iterations do
        local structure = Instance.new("Part")
        structure.Name = "Wall"
        structure.Size = Vector3.new(4, 8, 1) -- Wall dimensions
        structure.Anchored = true
        structure.CFrame = CFrame.new(0, 5, 0)
        structure.BrickColor = BrickColor.new("Brown")
        structure.Parent = workspace -- Expensive but realistic
        structure:Destroy()
    end
    local endBaseline = os.clock()
    local baselineTime = endBaseline - startBaseline

    -- Optimization: Clone
    local template = Instance.new("Part")
    template.Name = "Wall"
    template.Size = Vector3.new(4, 8, 1)
    template.Anchored = true
    template.BrickColor = BrickColor.new("Brown")

    local startOpt = os.clock()
    for _ = 1, iterations do
        local structure = template:Clone()
        structure.CFrame = CFrame.new(0, 5, 0)
        structure.Parent = workspace
        structure:Destroy()
    end
    local endOpt = os.clock()
    local optTime = endOpt - startOpt

    template:Destroy()

    print(string.format("Baseline (Instance.new): %.4f seconds", baselineTime))
    print(string.format("Optimization (Clone): %.4f seconds", optTime))

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
