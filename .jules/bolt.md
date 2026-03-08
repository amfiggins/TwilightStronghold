## 2025-03-08 - Optimize UDim2 allocations in UI hot loop
**Learning:** In Luau/Roblox UI development, `UDim2.new()` has unnecessary overhead parsing unused properties (like offsets) when creating simple UI scaling values, which adds up when used continuously inside a `RenderStepped` loop (like the Minigame UI updates).
**Action:** Use `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` instead of `UDim2.new(x, xo, y, yo)` in hot paths to skip unused property parsing and optimize main thread performance.
