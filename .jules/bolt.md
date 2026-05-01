
## 2024-05-24 - CFrame Array Allocation Optimization
**Learning:** Capturing `CFrame:GetComponents()` results in a table literal (e.g., `{cf:GetComponents()}`) causes expensive heap allocation and garbage collection overhead, especially in hot paths like anti-cheat validation.
**Action:** Assign the 12 returned numerical values directly to individual local variables to eliminate allocation and optimize performance.
