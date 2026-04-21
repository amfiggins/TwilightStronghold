## 2024-04-21 - [Optimize Magnitude in AI Hot Loops]
**Learning:** Using `.Magnitude` on `Vector3` in Roblox Luau involves an expensive square root operation and a C++ bridge crossing, causing a performance bottleneck inside hot paths like AI loops running repeatedly on multiple enemies.
**Action:** Replace `.Magnitude` comparisons with explicit squared distance calculations (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) against pre-computed squared thresholds.
