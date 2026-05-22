## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-05-22 - [Cache Players:GetPlayers() in AI loops]
**Learning:** Repeatedly calling `Players:GetPlayers()` inside frequent enemy AI loops creates a new table on every call, causing unnecessary allocations that degrade performance significantly with many agents.
**Action:** Cache the players list in a module-level variable and update it via `PlayerAdded` and `PlayerRemoving` events for O(1) table creation overhead in AI loops.
