# Bolt's Journal

## 2024-05-18 - [Optimization Pattern: Squared Distance & LOS]
**Learning:**
Heavy reliance on `ComputeAsync` (pathfinding) for every enemy every tick creates significant CPU overhead, especially when targets are close and visible.
Using `(p1 - p2).Magnitude` involves an expensive square root operation. Comparing squared distances (`(p1 - p2):Dot(p1 - p2)`) is mathematically equivalent for comparisons and avoids the `sqrt`.

**Action:**
1. Prefer `Vector3:Dot(Vector3)` for distance comparisons.
2. Implement a `Raycast` check to skip full pathfinding when there is a direct line of sight to the target.
