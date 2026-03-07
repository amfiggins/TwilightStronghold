## 2026-03-07 - Optimize UDim2 allocations in Minigame RenderStepped loop
**Learning:** `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` should be used in hot paths (like `RenderStepped` loops) instead of `UDim2.new()` to skip unused property parsing and optimize main thread performance.
**Action:** Replace `UDim2.new(x, 0, y, 0)` with `UDim2.fromScale(x, y)` inside tight rendering loops to prevent unnecessary property parsing and reduce allocation overhead.
