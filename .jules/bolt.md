## 2024-05-24 - [Optimize UDim2 in RenderStepped loops]
**Learning:** `UDim2.new()` creates overhead when updating positions and sizes by parsing all 4 scale and offset properties, which becomes a performance bottleneck inside hot paths like `RenderStepped`. `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` bypass unused property parsing.
**Action:** Always prefer `UDim2.fromScale` or `UDim2.fromOffset` over `UDim2.new` when rapidly updating positions or sizes in performance-critical loops such as `RunService.RenderStepped` to optimize main thread performance.
