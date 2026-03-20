## 2024-03-20 - Optimizing Tuple Returns in CFrame Validations
**Learning:** Wrapping tuple returns (like `CFrame:GetComponents()`) in a table literal to iterate over them creates unnecessary heap allocations and GC pressure, particularly in high-frequency validation functions like anti-cheat checks.
**Action:** Always capture multi-return values (tuples) directly into local variables when performance matters, avoiding intermediate table creation.
