## 2024-05-24 - Optimizing Hot Loops
**Learning:** Computing `.Magnitude` (which performs a square root) and allocating table literals (e.g. `{enemy, targetPlayer.Character}`) inside tight AI loops causes significant performance overhead and unnecessary GC pressure.
**Action:** Use squared distance comparisons and pre-allocate reusable tables outside the loop, updating their elements by index.
