## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-05-19 - O(1) Queue Membership Checks
**Learning:** In Roblox Luau, using `table.find` on large, frequently-accessed arrays like matchmaking queues results in O(N) complexity and potential server strain under high concurrency or spam.
**Action:** Use a companion dictionary (e.g., `queueSet[player] = true`) synchronized with the array to achieve O(1) membership lookups while preserving array order.
