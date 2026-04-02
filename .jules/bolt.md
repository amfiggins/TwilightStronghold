## 2024-05-15 - Squared Distance Optimization
**Learning:** Using `Vector3.Magnitude` in hot loops (like AI pathing and distance checks) introduces significant CPU overhead due to the square root operation.
**Action:** Always compute squared distance manually (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) and compare against `threshold * threshold` to avoid the square root overhead, improving efficiency by up to ~75% in hot paths.
