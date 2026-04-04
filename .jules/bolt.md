## 2024-04-04 - Initial Setup
**Learning:** Initializing Bolt journal.
**Action:** Keep track of critical performance learnings.

## 2024-04-04 - Magnitude vs Squared Distance Optimization
**Learning:** In Luau, calculating squared distance (delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z) is faster than `.Magnitude` because it avoids costly square root operations.
**Action:** Apply this optimization in hot paths like frequent AI loops.
