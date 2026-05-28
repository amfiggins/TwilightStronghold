--[[
    RetryBenchmark.lua
    Simulates and benchmarks the reliability improvement of a retry mechanism.
    Run this in Roblox Studio to verify the improvement.

    This script compares:
    1. Single Attempt (Baseline) - 20% failure rate
    2. Retry Logic (Optimized) - 20% failure rate, 3 retries
]]

local function simulateGetAsync(failureRate)
    if math.random() < failureRate then
        error("Simulated DataStore Error")
    end
    return { Status = "Success" }
end

local function singleAttempt(failureRate)
    local success, result = pcall(function()
        return simulateGetAsync(failureRate)
    end)
    return success
end

local function retryAttempt(failureRate, retries)
    local currentTry = 0
    local success, result

    while currentTry <= retries do
        success, result = pcall(function()
            return simulateGetAsync(failureRate)
        end)

        if success then
            return true
        else
            currentTry = currentTry + 1
            -- In a real scenario, we would wait here: task.wait(baseDelay * (2 ^ (currentTry - 1)))
        end
    end

    return false
end

-- Run benchmark
local iterations = 10000
local failureRate = 0.2 -- 20% failure rate

local singleSuccess = 0
for i = 1, iterations do
    if singleAttempt(failureRate) then singleSuccess = singleSuccess + 1 end
end

local retrySuccess = 0
for i = 1, iterations do
    if retryAttempt(failureRate, 3) then retrySuccess = retrySuccess + 1 end
end

print(string.format("--- Reliability Benchmark ---"))
print(string.format("Iterations: %d", iterations))
print(string.format("Failure Rate: %.0f%%", failureRate * 100))
print(string.format("Baseline (Single Attempt): %.2f%% Success Rate", (singleSuccess / iterations) * 100))
print(string.format("Optimized (3 Retries): %.2f%% Success Rate", (retrySuccess / iterations) * 100))
print(string.format("-----------------------------"))

-- Expected Output:
-- Baseline: ~80% Success Rate
-- Optimized: ~99.84% Success Rate (1 - 0.2^4)
