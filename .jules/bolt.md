## 2024-05-06 - Optimize CFrame:GetComponents() table allocation overhead
**Learning:** Capturing the 12 numerical returns of `CFrame:GetComponents()` into a table literal (e.g. `{cf:GetComponents()}`) causes significant heap allocation and garbage collection overhead in hot loops.
**Action:** Assign the returned values directly to individual local variables (e.g., `local x, y, z, r00, r01, ... = cf:GetComponents()`) to bypass table allocation entirely and optimize performance.
