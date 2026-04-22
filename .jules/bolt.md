## 2024-05-18 - Avoid Magnitude and Table Allocations in Hot Paths
**Learning:** In Roblox Luau, using `.Magnitude` incurs a C++ bridge crossing cost and a square root operation. Furthermore, allocating table literals (e.g., for `FilterDescendantsInstances`) inside tight loops generates unnecessary garbage, increasing GC pressure.
**Action:** Always compute explicit squared distances (`delta.X^2 + delta.Y^2 + delta.Z^2`) and compare against squared thresholds in hot paths. Pre-allocate local tables outside of loops and update indices for things like `RaycastParams` filters.
