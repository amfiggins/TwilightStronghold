## 2024-04-16 - Avoid .Magnitude in hot loops
**Learning:** Using .Magnitude requires an expensive square root calculation and crosses the C++ bridge.
**Action:** Calculate the explicit squared distance (dx * dx + dy * dy + dz * dz) and compare it against squared thresholds for faster execution in AI paths.
