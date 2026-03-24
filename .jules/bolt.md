
## 2026-03-24 - Optimization: Squared Distance Checks
**Learning:** Using `Vector3.Magnitude` involves costly square root calculations. In hot paths like the AI loop, computing the squared distance (`delta.X^2 + delta.Y^2 + delta.Z^2`) and comparing it against the squared threshold is significantly faster.
**Action:** Apply squared distance checks instead of `Magnitude` in high-frequency distance validation loops to reduce CPU overhead.
