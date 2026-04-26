## 2026-04-26 - Optimize Distance Calculations in Hot Loops
**Learning:** In Roblox Luau, using `.Magnitude` inside tight AI loops introduces significant overhead due to C++ bridge crossing and square root calculation. Explicit squared distance calculation is substantially faster and avoids this.
**Action:** Always prefer calculating squared distance manually (`dx*dx + dy*dy + dz*dz`) and compare it against squared thresholds for hot path spatial checks.
