## 2024-04-29 - Avoid Table Literal Allocations in Hot Paths
**Learning:** Allocating table literals like `{cf:GetComponents()}` generates significant garbage collection pressure.
**Action:** Capture multiple return values into local variables to avoid allocations.
