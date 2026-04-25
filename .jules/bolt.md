## 2024-04-25 - Squared Distance over .Magnitude
**Learning:** In Roblox Luau, using `.Magnitude` requires an expensive square root operation. In hot paths (like AI loops), calculating explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and comparing against squared thresholds is significantly faster and avoids C++ bridge crossing overhead.
**Action:** Replace `.Magnitude` checks with explicit squared distance math and squared threshold comparisons inside any high-frequency AI loops or spatial searches.
