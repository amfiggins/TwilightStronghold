## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-05-15 - Array to O(1) Dictionary Lookup for Queues
**Learning:** Ordered collections (like matchmaking queues) using `table.find` for membership checking introduce O(N) performance bottlenecks in hot paths.
**Action:** Always pair arrays with a synchronized companion dictionary (e.g., `queueSet[player] = true`) when membership checks are frequent, explicitly synchronizing the dictionary during all insertions, removals, and queue shifting/batch extractions.
