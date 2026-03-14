## 2024-05-14 - UDim2 Parsing Overhead in RenderStepped
**Learning:** `UDim2.new(scaleX, offsetX, scaleY, offsetY)` parses and processes four arguments, even if the offset values are unused (0). When called repeatedly in a hot loop (like `RunService.RenderStepped` for Minigame UI updates), this parsing adds unnecessary micro-overhead on the main thread.
**Action:** Always prefer `UDim2.fromScale(x, y)` or `UDim2.fromOffset(x, y)` in hot UI loops when constructing UDim2s that only rely on scale or offset, respectively.
