## 2024-05-24 - Prefer Raycasting over Pathfinding for Local Movement
**Learning:** `PathfindingService:ComputeAsync` is expensive, especially in a tight loop for many agents.
**Action:** Always check `(target - origin).Magnitude < CLOSE_RANGE` and use `workspace:Raycast` for Line-of-Sight first. If clear, move directly. Only fallback to full pathfinding if obstructed or far.
