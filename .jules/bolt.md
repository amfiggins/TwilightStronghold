## 2024-04-10 - Magnitude vs Distance Squared Optimization
**Learning:** Checking distance squared `delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z < threshold * threshold` is noticeably faster than `.Magnitude` in Roblox Luau because it avoids costly square root operations, especially in loops like finding the nearest player.
**Action:** Replace `(A - B).Magnitude` with `(A.X - B.X)^2 ...` or explicitly multiplying the components and testing against squared thresholds for hot-loop distance checks.
