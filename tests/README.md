# tests/

Automated and semi-automated tests for TwilightStronghold.

## Layout

```
tests/
  README.md             # this file
  unit/                 # pure-Lua unit tests (run anywhere, headless)
  integration/          # tests that need Roblox APIs (run in Studio or run-in-roblox)
  TestRunner.server.lua # Studio entry point — drag-imports nothing, requires the test modules and reports
```

## What works today

- `tests/unit/*.spec.lua` — TestEZ-style describe/it blocks using a tiny built-in shim. Run them in Studio by enabling the test runner (see "Run in Studio" below).
- The runner is **Studio-only by default**. It checks `RunService:IsStudio()` and exits early in production.

## What's not wired yet (Phase 0 follow-up)

- **CI execution.** Headless Roblox testing is not part of CI yet. Two viable paths when we want it:
  1. [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox) — runs a `.rbxl` in a real Studio session in CI.
  2. [Lune](https://github.com/lune-org/lune) — pure-Lua runtime with Roblox API stubs. Faster but not 100% API-compatible.
- **TestEZ proper.** Today we use a minimal in-repo shim. When tests grow, install [TestEZ](https://roblox.github.io/testez/) via Wally and replace the shim.

## Run in Studio

1. Open the synced place in Studio (via Rojo or the latest `.rbxl`).
2. The `TestRunner.server.lua` is **not** synced in production builds — to enable it, copy this folder into your local server-side scripts (or set up a separate `tests.project.json`).
3. Press Play. Tests print to the Output window with `[TEST] PASS` / `[TEST] FAIL`.

## Writing a test

```lua
-- tests/unit/MyModule.spec.lua
return function(test)
    test.describe("MyModule", function()
        test.it("does the thing", function()
            test.expect(2 + 2).toEqual(4)
        end)
    end)
end
```
