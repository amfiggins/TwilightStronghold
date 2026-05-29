# tests/

Two test surfaces with different runtimes:

```
tests/
  README.md           # this file
  lune/               # CI tests — pure-Lua modules, run via Lune
    runner.luau       #   - entry point
    *.test.luau       #   - one file per module under test
  unit/               # Studio integration tests (placeholder for now)
  TestFramework.lua   # TestEZ-style harness used by Studio specs
  TestRunner.server.lua  # Studio entry point — auto-discovers tests/unit/*.spec.lua
```

## Lune tests (CI)

Run on every PR via `.github/workflows/lint.yml`. They cover **pure-Lua modules** (anything in `src/shared/` that doesn't reference `game`, `workspace`, etc.).

Run locally:

```bash
lune run tests/lune/runner.luau
```

Add a new test:

1. Create `tests/lune/MyModule.test.luau` returning `function(test) ... end`. Use `require("../../src/shared/MyModule")` to import the module under test.
2. Add a `runSpec("MyModule", require("./MyModule.test"))` line in `tests/lune/runner.luau`.

Available assertions: `test.expect(value).toEqual(...)`, `.toBeTruthy()`, `.toBeFalsy()`, `.toThrow()`. Group tests with `test.describe(name, fn)` and `test.it(name, fn)`.

## Studio integration tests

For modules that need real Roblox APIs (Instance, RemoteEvent, DataStore, etc), drop a `*.spec.lua` file under `tests/unit/`. The Studio entry point `TestRunner.server.lua` auto-discovers and runs them when the test project is loaded in Studio.

Run locally:

```bash
rojo build tests.project.json --output build/tests.rbxl
# Open build/tests.rbxl in Roblox Studio and press Play.
```

These are **not in CI today**. Wiring them up requires either [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox) (needs a Studio install on the runner) or extending the Lune harness with an `@lune/roblox` shim that mounts `src/` files as fake ModuleScripts. Tracked in `docs/VISION.md` §4 backlog.
