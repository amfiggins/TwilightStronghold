## 2024-05-24 - UDim2 Allocation in Hot Loops
**Learning:** Using `UDim2.new(scaleX, offsetX, scaleY, offsetY)` in hot loops like `RenderStepped` creates unnecessary overhead by parsing unused properties, especially when only scale or offset is needed.
**Action:** Use `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` instead to optimize main thread performance.
