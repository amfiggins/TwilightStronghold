## 2024-05-19 - Initial Learnings
**Learning:** Checking distance squared (x^2 + y^2 + z^2) is faster than `.Magnitude` since it avoids square roots. Apply to hot paths.
**Action:** Use squared distance checks in loops like `WaveManager.lua`.

## 2024-05-19 - Fast Distance Checks
**Learning:** Comparing squared distance (delta.X^2 + delta.Y^2 + delta.Z^2) against a squared threshold is significantly faster than using Vector3.Magnitude because it skips the costly square root operation.
**Action:** Use squared distance comparisons in hot paths like frequent distance validation checks and AI pathfinding loops.
