## 2024-05-24 - Faster Distance Checks
**Learning:** In Roblox Luau, using `(a - b).Magnitude` involves a costly square root computation. In hot loops like pathfinding AI loops or validation checks, computing the squared distance manually (`local delta = a - b; local distSq = delta.X^2 + delta.Y^2 + delta.Z^2`) and comparing against a squared threshold is significantly faster.
**Action:** Always use squared distance comparisons (`distSq < threshold^2`) instead of `.Magnitude` when only a simple distance threshold check is needed and the exact linear distance isn't required.
