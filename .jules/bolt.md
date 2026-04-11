## 2024-04-11 - Fast Distance Checks
**Learning:** In Roblox Luau, comparing squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < threshold * threshold`) is significantly faster than using `Vector3.Magnitude` because it avoids costly square root operations. Furthermore, explicit multiplication (`x * x`) benchmarks faster than the exponent operator (`x^2`).
**Action:** Apply this optimization in hot paths like AI loops or frequent distance validation checks to reduce CPU overhead.
