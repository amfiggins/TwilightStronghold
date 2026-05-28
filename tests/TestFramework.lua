--!strict
--[[
    TestFramework.lua
    Tiny TestEZ-style harness used until we adopt TestEZ proper via Wally.
    Each *.spec.lua file returns: function(test) ... end and uses:
      - test.describe(name, fn)
      - test.it(name, fn)
      - test.expect(value).toEqual(expected)
      - test.expect(value).toBeTruthy()
      - test.expect(value).toBeFalsy()
      - test.expect(fn).toThrow()
]]

local TestFramework = {}

type Stats = { passed: number, failed: number, failures: { string } }

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

-- Run a single spec file. Returns updated stats.
function TestFramework.run(specName: string, spec: (any) -> (), stats: Stats)
    local context = { describe = "", it = "" }

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
            warn(string.format("[TEST] FAIL %s: %s", label, tostring(err)))
        end
    end

    test.expect = makeExpectation

    spec(test)
    return stats
end

return TestFramework
