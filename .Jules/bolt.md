## 2024-06-18 - [Optimizing RenderStepped UI updates]
**Learning:** In Luau/Roblox UI development, `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` should be used in hot paths (like `RenderStepped` loops) instead of `UDim2.new()` to skip unused property parsing and optimize main thread performance.
**Action:** When updating position or size properties within `RenderStepped` loops, always use `UDim2.fromScale` or `UDim2.fromOffset` instead of the more general `UDim2.new()`.
