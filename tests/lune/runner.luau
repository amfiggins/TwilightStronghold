--!strict
--[[
    tests/lune/runner.luau
    Headless CI test runner. Hand-curated list of pure-Lua tests that run
    under Lune (no Roblox runtime needed).

    Usage:
        lune run tests/lune/runner.luau

    Adding a test:
        1. Create tests/lune/MyModule.test.luau that returns
           function(test) test.describe(...) ... end
        2. Add a require below.

    Tests that need Roblox APIs (Instance, RemoteEvent, DataStore) live
    under tests/unit/*.spec.lua and run inside Studio via
    tests/TestRunner.server.lua. They're not part of CI today.
]]

local process = require("@lune/process")

local stats = { passed = 0, failed = 0, failures = {} :: { string } }

local function makeExpectation(value: any)
    local exp = {}
    function exp.toEqual(expected: any)
        if value ~= expected then
            error(string.format("expected %s, got %s", tostring(expected), tostring(value)), 2)
        end
    end
    function exp.toBeTruthy()
        if not value then
            error(string.format("expected truthy, got %s", tostring(value)), 2)
        end
    end
    function exp.toBeFalsy()
        if value then
            error(string.format("expected falsy, got %s", tostring(value)), 2)
        end
    end
    function exp.toThrow()
        if type(value) ~= "function" then
            error("toThrow() requires a function", 2)
        end
        local ok = pcall(value)
        if ok then
            error("expected function to throw, but it succeeded", 2)
        end
    end
    return exp
end

local function makeTest(specName: string)
    local context = { describe = "" }
    local test = {}

    function test.describe(name: string, fn: () -> ())
        local prev = context.describe
        context.describe = name
        local ok, err = pcall(fn)
        if not ok then
            stats.failed = stats.failed + 1
            table.insert(stats.failures, string.format("%s > %s: %s", specName, name, tostring(err)))
        end
        context.describe = prev
    end

    function test.it(name: string, fn: () -> ())
        local label = string.format("%s > %s > %s", specName, context.describe, name)
        local ok, err = pcall(fn)
        if ok then
            stats.passed = stats.passed + 1
            print(string.format("[TEST] PASS %s", label))
        else
            stats.failed = stats.failed + 1
            table.insert(stats.failures, string.format("%s: %s", label, tostring(err)))
            print(string.format("[TEST] FAIL %s: %s", label, tostring(err)))
        end
    end

    test.expect = makeExpectation
    return test
end

local function runSpec(name: string, spec: (any) -> ())
    spec(makeTest(name))
end

-- ── Test list ─────────────────────────────────────────────────────────────
-- Add new entries here when you author a new pure-Lua spec.
runSpec("ItemDatabase", require("./ItemDatabase.test"))
runSpec("Vitals", require("./Vitals.test"))
runSpec("Weapons", require("./Weapons.test"))
runSpec("CropDatabase", require("./CropDatabase.test"))
runSpec("BeastDatabase", require("./BeastDatabase.test"))

-- ── Report ────────────────────────────────────────────────────────────────
print(string.format("[TEST] === %d passed, %d failed ===", stats.passed, stats.failed))
if stats.failed > 0 then
    print("[TEST] Failures:")
    for _, failure in ipairs(stats.failures) do
        print("  " .. failure)
    end
    process.exit(1)
end
