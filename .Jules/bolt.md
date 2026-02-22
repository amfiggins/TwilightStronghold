## 2024-10-24 - [Roblox Pathfinding Optimization]
**Learning:** `PathfindingService:ComputeAsync` is an expensive blocking operation. For enemies chasing players, frequently recomputing paths when there is a direct line of sight (LOS) and short distance is wasteful.
**Action:** Implement a short-range Raycast check. If the enemy has LOS and is close (< 30 studs), skip `ComputeAsync` and use `Humanoid:MoveTo(targetPos)` directly. This significantly reduces CPU usage in high-enemy-count scenarios.
