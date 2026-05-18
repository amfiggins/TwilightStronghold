## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.

## 2024-05-18 - Matchmaking Queue O(1) Lookups
**Learning:** Using `table.find` to check membership in an ordered array (like a queue) results in O(N) complexity, causing unnecessary overhead as the queue grows.
**Action:** Implement a companion dictionary (`queueSet = {}`) alongside the array to achieve O(1) membership checks. Synchronize the set during all queue operations (add, remove, process).
