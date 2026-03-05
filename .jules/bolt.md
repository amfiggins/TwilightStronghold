## 2023-10-27 - [Optimize UDim2 Initialization in Hot Loops]
**Learning:** In Luau/Roblox UI development, `UDim2.new(xScale, xOffset, yScale, yOffset)` has slight overhead due to property parsing. When executing UI updates in hot paths like `RenderStepped` loops, omitting unused properties is preferred to optimize main thread performance.
**Action:** Use `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` over `UDim2.new()` whenever only scale or offset values are being modified, especially inside tight loops like `RunService.RenderStepped` to reduce parsing overhead and micro-allocations.
