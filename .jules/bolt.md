
## 2024-05-24 - Optimization: Use Squared Distance over Vector3.Magnitude
**Learning:** In Roblox Luau, comparing squared distance (`delta.X^2 + delta.Y^2 + delta.Z^2`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations. This is especially impactful in hot paths like AI loops or frequent distance validation checks.
**Action:** Apply squared distance checks instead of `Magnitude` when comparing distances against fixed thresholds, especially in frequent loops.
