## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-04-09 - O(1) Queue Lookups
**Learning:** In Roblox Luau, using `table.find` for membership checks in ordered collections like queues is an $O(N)$ operation that can slow down performance under heavy load or large queue sizes.
**Action:** Always use a companion dictionary (e.g., `queueSet = {}`) alongside the array to achieve $O(1)$ lookups, ensuring it is explicitly synchronized during insertions, removals, and batch processing.
