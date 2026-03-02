## 2024-03-02 - [UI Loop Allocation Optimization]
**Learning:** Calling `UDim2.new(scaleX, 0, scaleY, 0)` inside hot loops like `RenderStepped` performs unnecessary scale and offset argument parsing.
**Action:** Use `UDim2.fromScale(scaleX, scaleY)` and `UDim2.fromOffset(offsetX, offsetY)` when only one type of coordinate is needed to reduce UI property update overhead on the main thread.
