## 2024-05-24 - Avoid table allocations in hot paths like CFrame:GetComponents()
**Learning:** In Roblox Luau, `CFrame:GetComponents()` returns 12 numerical values. In performance-critical validation checks, capturing these as an array literal (`local components = {cf:GetComponents()}`) creates heap allocations and garbage collection pressure in hot paths.
**Action:** Unpack them directly into variables: `local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()`.

## 2024-05-24 - Use squared distance checks instead of .Magnitude
**Learning:** In Roblox Luau, using `.Magnitude` requires an expensive square root operation. In hot paths (like AI loops or interaction checks), calculating explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and comparing against squared thresholds is significantly faster.
**Action:** Replace `(p1 - p2).Magnitude < dist` with `distSq < dist * dist`.
