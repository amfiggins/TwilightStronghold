
## 2024-05-08 - Avoid .Magnitude in Hot Loops
**Learning:** In Roblox Luau, replacing `.Magnitude` with explicit squared distance calculations (e.g., `delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) avoids expensive square root math and C++ bridge crossings, significantly improving performance in hot loops.
**Action:** Always prefer squared distance comparisons against squared thresholds when checking ranges in high-frequency loops (like enemy AI or frequent spatial queries).
