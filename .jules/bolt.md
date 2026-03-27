
## 2024-03-27 - Fast distance checks
**Learning:** In hot loops like AI pathfinding, replacing Vector3.Magnitude with squared distance calculations (delta.X^2 + delta.Y^2 + delta.Z^2) bypasses costly square root operations, significantly improving performance.
**Action:** Always prefer squared distance comparisons (distSq < thresholdSq) when exact distance values are not strictly required for logic, especially in high-frequency update loops.
