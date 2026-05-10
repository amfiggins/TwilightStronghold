## 2024-05-24 - explicit squared distance over .Magnitude
**Learning:** In Roblox Luau, replacing `.Magnitude` with explicit squared distance calculations (e.g., `delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) significantly improves performance in hot loops by avoiding expensive square root math and C++ bridge crossings.
**Action:** When calculating distance purely for comparison (like distance thresholds), calculate the squared distance and compare it against squared thresholds (e.g., `distSq > 10000` instead of `dist > 100`).
