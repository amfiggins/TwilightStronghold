## 2024-05-24 - Squared Distance Optimization
**Learning:** In Roblox Luau, comparing squared distance (e.g., `delta.X^2 + delta.Y^2 + delta.Z^2 < threshold^2`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations, which is critical in hot paths like AI pathfinding loops.
**Action:** Always prefer squared distance calculations over `.Magnitude` when checking if a distance is within a specific threshold, especially inside frequent loops.
