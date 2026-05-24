## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-05-17 - Optimize GetPlayers in WaveManager
**Learning:** Calling `Players:GetPlayers()` on every AI tick allocates a new array, causing severe garbage collection pressure when there are many active enemies.
**Action:** Maintain a module-level cached list of players that is synchronized using `Players.PlayerAdded` and `Players.PlayerRemoving` to avoid allocations in high-frequency loops.
