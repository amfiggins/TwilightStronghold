## 2024-05-24 - Distance Calculation Optimization
**Learning:** In Luau, calculating `.Magnitude` (which involves a square root) is significantly slower than calculating the squared distance explicitly (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) when doing simple threshold comparisons.
**Action:** Use squared distance comparisons in hot loops like AI targeting (`findNearestPlayer` in WaveManager) to avoid costly square root operations.
