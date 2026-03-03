## 2024-05-18 - [Optimize UDim2 calls in hot loops]
**Learning:** `UDim2.new()` creates noticeable main thread parsing overhead when used repeatedly in hot loops like `RenderStepped`.
**Action:** Use `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` instead for simple assignments within these loops to significantly reduce overhead.