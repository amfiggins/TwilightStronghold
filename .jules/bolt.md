## 2026-04-20 - Avoid .Magnitude in Hot Paths
**Learning:** Using `.Magnitude` on Vector3s in Roblox Luau involves an expensive square root operation. In hot paths like AI loops checking distances frequently, this adds significant C++ bridge crossing overhead and CPU cost.
**Action:** Calculate explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and compare against squared thresholds (e.g., `distSq < 900` instead of `dist < 30`).
