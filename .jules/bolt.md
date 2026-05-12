## 2024-04-08 - Fast Distance Calculations
**Learning:** In Roblox Luau, comparing squared distance using explicit multiplication (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < thresholdSq`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations and property getter overhead.
**Action:** Always use squared distance checks in hot paths like AI loops, frequent position validation, or finding the nearest target.
## 2024-05-12 - Ordered Collection Lookups
**Learning:** Using `table.find` to check membership in an ordered array (like a matchmaking queue) results in $O(N)$ lookups, which scales poorly and wastes CPU time.
**Action:** When managing ordered collections that require frequent membership checks, use a companion dictionary (`{[element] = true}`) alongside the array to achieve $O(1)$ lookups. Ensure the dictionary is explicitly synchronized during insertions, removals, and batch processing.
