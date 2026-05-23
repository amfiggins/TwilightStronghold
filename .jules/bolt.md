## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.

## 2026-05-23 - Optimize Players:GetPlayers() with Caching
**Learning:** Calling `Players:GetPlayers()` inside high-frequency loops (like per-frame pathfinding or constant loops) allocates a new table on every invocation. This generates unnecessary garbage collection overhead and burns CPU cycles simply constructing the table.
**Action:** When a loop iterates over all players frequently, maintain a cached array of players at the module level. Keep the cache synchronized using the `Players.PlayerAdded` and `Players.PlayerRemoving` events, and iterate over the cached array instead.
