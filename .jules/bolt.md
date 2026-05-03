## 2024-05-18 - Avoid Table Allocations in CFrame:GetComponents()
**Learning:** Calling `CFrame:GetComponents()` and wrapping the results in a table literal (e.g., `{cf:GetComponents()}`) causes expensive heap allocation and garbage collection overhead, which makes it about 50% slower than explicitly declaring the 12 local variables.
**Action:** Always assign the 12 returned values of `CFrame:GetComponents()` directly to individual local variables to avoid creating an intermediate table.
