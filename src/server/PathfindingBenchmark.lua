local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local function benchmark()
    local iterations = 100

    -- Setup mock environment
    local startPos = Vector3.new(0, 5, 0)
    local endPos = Vector3.new(100, 5, 100)

    -- Create some obstacles
    local obstacle = Instance.new("Part")
    obstacle.Size = Vector3.new(20, 10, 2)
    obstacle.Position = Vector3.new(50, 5, 50)
    obstacle.Anchored = true
    obstacle.Parent = Workspace

    -- 1. Measure ComputeAsync
    local path = PathfindingService:CreatePath()
    local startCompute = os.clock()
    for i = 1, iterations do
        pcall(function()
            path:ComputeAsync(startPos, endPos)
        end)
    end
    local endCompute = os.clock()
    local computeTime = endCompute - startCompute

    -- 2. Measure Raycast (for line of sight check optimization)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local startRay = os.clock()
    for i = 1, iterations do
         Workspace:Raycast(startPos, endPos - startPos, rayParams)
    end
    local endRay = os.clock()
    local rayTime = endRay - startRay

    print(string.format("Pathfinding ComputeAsync (%d iters): %.4f seconds", iterations, computeTime))
    print(string.format("Raycast (%d iters): %.4f seconds", iterations, rayTime))
    if rayTime > 0 then
        print(string.format("Ratio (Compute/Raycast): %.2f", computeTime / rayTime))
    else
        print("Raycast time too small to measure ratio")
    end

    obstacle:Destroy()
end

return benchmark
