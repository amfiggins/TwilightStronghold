# dev/

Non-production scripts: benchmarks, verification scripts, ad-hoc tests.

This folder is **not** referenced by any Rojo project file, so nothing here ships to Roblox. To run something here:

- **Benchmarks** (`*Benchmark.lua`) — copy into Studio's command bar or paste-import as a ModuleScript. Each returns a `benchmark()` callable.
- **Verify scripts** (`Verify*.server.lua`) — paste into a Script in `ServerScriptService` while testing in Studio. Their original auto-run behavior is preserved.
- **Tests** (`*Test.lua`) — copy and require from the command bar.

If you want one of these to run in production, move it back into `src/server/` and gate it with `if not RunService:IsStudio() then return end` so it stays Studio-only by default.
