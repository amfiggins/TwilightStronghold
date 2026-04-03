## 2024-04-03 - Avoid Vector3.Magnitude in hot loops
**Learning:** Using `Vector3.Magnitude` involves a costly square root operation. In hot paths like continuous AI distance checks or frequent distance validation, this adds up and degrades performance.
**Action:** Compare squared distances (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < threshold * threshold`) instead of using `.Magnitude`.
