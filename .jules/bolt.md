## 2025-04-05 - Optimize Vector3 magnitude distance calculations
**Learning:** Using `.Magnitude` on `Vector3` triggers an expensive square root operation, which becomes a bottleneck in hot paths (like looping over enemies and checking player distances every tick).
**Action:** Replace `(a - b).Magnitude` with explicitly squared distances (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) in hot loops where direct distance comparison against a threshold is acceptable, as this avoids square roots and significantly cuts CPU usage.
