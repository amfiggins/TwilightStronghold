## 2024-05-18 - Optimize UI Hot Path Allocations
**Learning:** In Luau/Roblox UI development, calling `UDim2.new(scaleX, 0, scaleY, 0)` inside hot loops (like `RenderStepped`) forces unnecessary property parsing for unused offset values.
**Action:** Always use `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` in `RenderStepped` loops or frequent state updates to optimize main thread performance.
