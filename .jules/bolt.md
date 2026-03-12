## 2024-05-14 - Optimize CFrame Finite Number Validation
**Learning:** During finite-number validation, unpacking the 12 components of a CFrame into a table (`{cf:GetComponents()}`) causes unnecessary table allocation overhead. This overhead adds up significantly in hot paths or frequently called validation functions.
**Action:** When validating CFrame components, capture all 12 components directly into local variables (e.g., `local x, y, z, ... = cf:GetComponents()`) to avoid table allocation overhead.
