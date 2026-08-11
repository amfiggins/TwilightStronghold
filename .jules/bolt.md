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

## 2024-08-11 - Caching Tween and String Operations in High-Frequency Loops
**Learning:** Unconditionally calling `TweenService:Create` and allocating strings (via `string.format`) within high-frequency loops like `RunService.RenderStepped` causes severe garbage collection overhead.
**Action:** Cache static `TweenInfo` objects and conditionally create Tweens/strings only when the underlying state (e.g., health ratio or integer time seconds) changes beyond a small tolerance threshold (e.g., `> 0.001`).
