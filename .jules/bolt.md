## 2024-04-18 - Avoid .Magnitude in Hot Loops
**Learning:** In Roblox Luau, using `.Magnitude` requires an expensive square root operation and C++ bridge crossing. In hot paths (like AI loops), calculating explicit squared distance is significantly faster (~20% improvement).
**Action:** Calculate explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and compare against squared thresholds in hot loops.
