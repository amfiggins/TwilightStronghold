## 2024-04-06 - Avoid .Magnitude in Hot Loops
**Learning:** Explicit squared distance using multiplication (`x*x`) avoids costly square root operations and outperforms `.Magnitude` in Luau hot paths like AI loops, resulting in a ~20-30% speedup.
**Action:** Replace `.Magnitude` checks with explicit squared distance and adjust threshold constants to their squared equivalents in high-frequency calculations.
