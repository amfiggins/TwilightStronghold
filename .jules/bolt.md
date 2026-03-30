## 2024-03-30 - Fast Distance Checks
**Learning:** In Roblox Luau, comparing squared distance (e.g., `delta.X^2 + delta.Y^2 + delta.Z^2 < threshold^2`) is significantly faster than using `Vector3.Magnitude` because it avoids computationally expensive square root operations.
**Action:** Apply squared distance calculations in hot paths like frequent AI loop distance checks to reduce CPU load.
