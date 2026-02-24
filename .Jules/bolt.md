## 2024-05-22 - AI Pathfinding Optimization
**Learning:** Constant re-calculation of paths using `ComputeAsync` is expensive in this codebase.
**Action:** Implement a lightweight Raycast Line-of-Sight (LOS) check before pathfinding. If the target is close and visible, move directly. This saves significant CPU time.
