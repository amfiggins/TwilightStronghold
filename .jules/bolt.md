## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.

## 2024-05-21 - O(1) Lookup for Ordered Collections
**Learning:** Checking for membership in an ordered array (like a matchmaking queue) using `table.find` requires an O(N) scan, which scales poorly.
**Action:** Use a companion dictionary/set alongside the array to achieve O(1) membership lookups while preserving order, explicitly synchronizing it during insertions, removals, and batch processing.

## 2024-05-25 - Caching Players List
**Learning:** Calling `Players:GetPlayers()` allocates a new array on every invocation, leading to significant garbage collection overhead in high-frequency loops (like AI per-frame updates).
**Action:** Cache the player list in a module-level table and keep it synchronized using `Players.PlayerAdded` and `Players.PlayerRemoving` events.

## 2024-05-26 - GetConnectedGamepads Allocation Overhead
**Learning:** Calling `UserInputService:GetConnectedGamepads()` repeatedly (e.g., inside a `RenderStepped` loop) allocates a new table on every invocation, causing unnecessary garbage collection pressure and stuttering in high-frequency loops.
**Action:** Always maintain a module-level cached list of gamepads using the `GamepadConnected` and `GamepadDisconnected` events instead of polling `GetConnectedGamepads()` every frame.

## 2024-08-09 - RenderStepped Allocation Overhead
**Learning:** Unconditionally creating Tweens (via `TweenService:Create`) and allocating strings (via `string.format` or Text assignments) within high-frequency loops like `RenderStepped` causes severe garbage collection overhead and frame drops.
**Action:** Always cache underlying state values (using small thresholds like `math.abs(new - old) > 0.001` for floats, or integer equivalence for timers) and only conditionally update the UI and create new Tweens when the state meaningfully changes. Cache static `TweenInfo` objects as top-level constants.
