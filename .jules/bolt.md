## 2024-03-19 - Avoid Table Allocation in Hot Paths for Tuple Returns
**Learning:** In Luau, wrapping tuple returns (like `CFrame:GetComponents()`) in a table literal (e.g., `{cf:GetComponents()}`) to iterate over them causes unnecessary heap allocations and GC pressure. They should be captured directly into local variables, especially in hot paths.
**Action:** Extract tuple returns from hot loop functions into local variables instead of allocating tables.
