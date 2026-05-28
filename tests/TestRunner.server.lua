--[[
    TestRunner.server.lua
    Studio-only entry point. Iterates every *.spec.lua module under tests/
    and runs it with TestFramework.

    This file lives outside the synced project tree (the production Rojo
    project does not reference tests/), so it ships nowhere. It runs only
    when you opt-in via a tests.project.json (TODO: Phase 0 follow-up).
]]
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
    return
end

local TestFramework = require(script.Parent.TestFramework)

local stats = { passed = 0, failed = 0, failures = {} }

-- Each spec module is expected to be a sibling of TestRunner under tests/unit/
-- or tests/integration/. When wired into Studio (via tests.project.json), the
-- folder structure is preserved as ModuleScripts.
local function runFolder(folder: Folder)
    if not folder then
        return
    end
    for _, child in ipairs(folder:GetDescendants()) do
        if child:IsA("ModuleScript") and child.Name:match("%.spec$") then
            local ok, spec = pcall(require, child)
            if ok and type(spec) == "function" then
                TestFramework.run(child.Name, spec, stats)
            else
                stats.failed = stats.failed + 1
                table.insert(stats.failures, string.format("%s: failed to require: %s", child.Name, tostring(spec)))
                warn(string.format("[TEST] FAIL %s: failed to require: %s", child.Name, tostring(spec)))
            end
        end
    end
end

runFolder(script.Parent:FindFirstChild("unit"))
runFolder(script.Parent:FindFirstChild("integration"))

print(string.format("[TEST] === %d passed, %d failed ===", stats.passed, stats.failed))
if stats.failed > 0 then
    for _, failure in ipairs(stats.failures) do
        warn("[TEST]   " .. failure)
    end
end
