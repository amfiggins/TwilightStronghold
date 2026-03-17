
## 2024-03-17 - [UDim2 instantiation in hot loops]
**Learning:** Instantiating new UI size/position definitions `UDim2.new()` with unused parameters in a hot loop (like `RenderStepped`) introduces unnecessary property parsing and CPU overhead on the main thread.
**Action:** Use `UDim2.fromScale(x, y)` and `UDim2.fromOffset(x, y)` instead for hot loops to skip unused property parsing and optimize main thread performance.
