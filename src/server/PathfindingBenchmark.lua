local PathfindingService = game:GetService("PathfindingService")

local function benchmark()
    local iterations = 100
    print(string.format("Running Pathfinding vs Raycast benchmark with %d iterations...", iterations))

    local startPos = Vector3.new(0, 5, 0)
    local endPos = Vector3.new(20, 5, 0)

    -- Setup dummy obstacles to simulate complexity
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 10, 2)
    part.Position = Vector3.new(10, 5, 5) -- Slightly offset so raycast might pass depending on angle
    part.Anchored = true
    part.Parent = workspace

    -- Benchmark Raycast
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {}

    local startRay = os.clock()
    for i = 1, iterations do
        local direction = (endPos - startPos)
        local result = workspace:Raycast(startPos, direction, raycastParams)
    end
    local endRay = os.clock()
    local rayTime = endRay - startRay

    -- Benchmark ComputeAsync
    local path = PathfindingService:CreatePath()

    local startPath = os.clock()
    for i = 1, iterations do
        pcall(function()
            path:ComputeAsync(startPos, endPos)
        end)
    end
    local endPath = os.clock()
    local pathTime = endPath - startPath

    print(string.format("Raycast Time: %.4f seconds", rayTime))
    print(string.format("ComputeAsync Time: %.4f seconds", pathTime))

    if rayTime > 0 then
        print(string.format("Raycast is %.2fx faster", pathTime / rayTime))
    else
        print("Raycast was too fast to measure accurately.")
    end

    part:Destroy()
end

if game then
    -- task.spawn(benchmark) -- Benchmark is now manually run to avoid production overhead
end

return benchmark
