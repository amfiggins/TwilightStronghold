## 2024-04-15 - Replace .Magnitude with squared distance
**Learning:** In Luau, .Magnitude requires crossing the C++ bridge and computing a square root. In hot AI loops (like checking distance to targets every frame or tick), this overhead adds up.
**Action:** Use squared distances `delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z` and compare against squared thresholds (e.g. `distSq > 10000` instead of `dist > 100`) to improve performance.
