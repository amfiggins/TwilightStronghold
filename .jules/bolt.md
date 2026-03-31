
## 2024-03-31 - Use Squared Distance Over Vector3.Magnitude
**Learning:** Calculating `Vector3.Magnitude` uses an expensive square root operation. Benchmarking showed that using squared distance (e.g., `delta.X^2 + delta.Y^2 + delta.Z^2`) avoids this overhead, resulting in a ~22% performance improvement in hot loops.
**Action:** Always prefer comparing squared distances against squared thresholds in frequent spatial checks (like AI tracking loops) instead of calculating exact magnitudes.
