## 2024-05-10 - Avoid .Magnitude in Hot Loops
**Learning:** In Roblox Luau, using `.Magnitude` requires an expensive square root operation and crosses the C++ bridge. In hot paths (like AI loops processing every tick), this introduces measurable overhead.
**Action:** Calculate explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and compare against squared thresholds to significantly improve execution speed and reduce overhead.
