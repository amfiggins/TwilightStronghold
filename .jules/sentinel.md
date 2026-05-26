## 2024-05-26 - NaN Spatial Bypass
**Vulnerability:** Players could send NaN positions in CFrames or other coordinates, which when compared using `distSq > MAX`, evaluate to false, bypassing distance checks.
**Learning:** In Luau, any relational comparison (`>`, `<`, `>=`, `<=`, `==`) with NaN evaluates to false. This allows exploiters to spoof positions and bypass distance-based security checks.
**Prevention:** Always use inverted logic `not (distSq <= MAX)` to catch both distances over the maximum and NaN values, and avoid using formatting or `math.sqrt` on raw distance values which might be NaN.

## 2024-05-26 - NaN Spatial Bypass
**Vulnerability:** Players could send NaN positions in CFrames or other coordinates, which when compared using `distSq > MAX`, evaluate to false, bypassing distance checks.
**Learning:** In Luau, any relational comparison (`>`, `<`, `>=`, `<=`, `==`) with NaN evaluates to false. This allows exploiters to spoof positions and bypass distance-based security checks.
**Prevention:** Always use inverted logic `not (distSq <= MAX)` to catch both distances over the maximum and NaN values, and avoid using formatting or `math.sqrt` on raw distance values which might be NaN.
