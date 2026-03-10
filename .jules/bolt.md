# Bolt's Performance Journal

## 2024-05-24 - Optimize `UDim2` Creation in RenderStepped UI Hot Loops
**Learning:** Calling `UDim2.new` continuously in a hot loop like `RenderStepped` for UI updates incurs a small but cumulative performance cost due to parsing unused offset properties.
**Action:** Always use `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` in hot UI loops instead of `UDim2.new` to optimize main thread performance by skipping unnecessary parsing steps.