## 2024-05-23 - Squared Distance & Raycast Optimization
**Learning:** `Vector3:Dot(offset, offset)` (squared magnitude) is ~35% faster than `Vector3.Magnitude` for distance comparisons in tight loops. Additionally, `workspace:Raycast` is significantly cheaper than `PathfindingService:ComputeAsync` and can be used to short-circuit pathfinding for close, visible targets.
**Action:** Always prefer squared distance for comparisons in update loops. Use Raycast to optimize AI movement when direct line-of-sight is likely.
