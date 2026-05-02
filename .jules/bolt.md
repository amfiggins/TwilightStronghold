## 2024-05-02 - Squared Distance in AI Loops
**Learning:** Calculating explicit squared distance (`delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z`) instead of `.Magnitude` avoids C++ bridge crossing overhead and expensive square root operations, significantly improving performance in hot paths like AI loops.
**Action:** Always use squared distance comparisons against squared thresholds in frequent update loops to optimize Vector3 distance checks.
