## 2024-05-24 - Avoid Vector3.Magnitude in Hot Loops
**Learning:** In Roblox Luau, using `.Magnitude` requires an expensive square root operation. In hot paths like AI loops or frequent distance checks, calculating explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and comparing against squared thresholds is significantly faster and avoids C++ bridge crossing overhead.
**Action:** Replace `.Magnitude` with explicit squared distance comparisons when finding nearest entities or checking distance thresholds in tight loops.
