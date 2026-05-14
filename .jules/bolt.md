## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2026-05-14 - O(1) Queue Set Optimization
**Learning:** Checking for membership in an array using `table.find` scales at O(N). In systems that frequently validate player state (like Matchmaking Queues or periodic processing loops), this can create measurable CPU load overhead.
**Action:** Always pair ordered collections (like arrays) that require frequent membership lookups with a companion dictionary/set (`{[player] = true}`). This ensures O(1) lookup times while preserving order, significantly boosting performance.
