## 2025-03-09 - [Optimize UI Creation in Hot Loops]
**Learning:** In Luau/Roblox UI development, `UDim2.new()` has overhead due to unused property parsing when setting scale or offset exclusively. Using `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` is more performant.
**Action:** Always prefer `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` over `UDim2.new()` in hot paths (like `RenderStepped` loops) to optimize main thread performance.
