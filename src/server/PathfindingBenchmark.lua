local PathfindingService = game:GetService("PathfindingService")

local function benchmark()
    local iterations = 100
    local startPos = Vector3.new(0, 5, 0)
    local targetPos = Vector3.new(20, 5, 0) -- Clear line of sight, 20 studs away

    print(string.format("Running Pathfinding Benchmark with %d iterations...", iterations))

    -- Setup for Raycast
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Baseline: ComputeAsync always
    local startBaseline = os.clock()
    local path = PathfindingService:CreatePath()
    for i = 1, iterations do
        pcall(path.ComputeAsync, path, startPos, targetPos)
    end
    local endBaseline = os.clock()
    local baselineTime = endBaseline - startBaseline

    -- Optimization: Raycast check
    local startOpt = os.clock()
    for i = 1, iterations do
        local direction = targetPos - startPos
        local distance = direction.Magnitude

        if distance < 30 then
            local result = workspace:Raycast(startPos, direction, raycastParams)
            if not result then
                -- Direct line of sight (simulated success)
            else
                pcall(path.ComputeAsync, path, startPos, targetPos)
            end
        else
             pcall(path.ComputeAsync, path, startPos, targetPos)
        end
    end
    local endOpt = os.clock()
    local optTime = endOpt - startOpt

    print(string.format("Baseline (ComputeAsync): %.4f seconds", baselineTime))
    print(string.format("Optimization (Raycast Check): %.4f seconds", optTime))
    print(string.format("Improvement: %.2f%%", ((baselineTime - optTime) / baselineTime) * 100))
end

if game then
    -- task.spawn(benchmark) -- Commented out to avoid auto-run
end

return benchmark
