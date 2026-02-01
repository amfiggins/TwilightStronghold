## 2024-05-21 - Trusting Client CFrame
**Vulnerability:** The `BuildingSystem` trusted the client-provided `CFrame` without validating the distance from the player, allowing players to build structures anywhere in the game world (Infinite Reach).
**Learning:** RemoteEvents accepting position data (Vector3, CFrame) are prime targets for exploits if the server assumes the client only sends "valid" or "reachable" coordinates.
**Prevention:** Always validate that the target position of an interaction is within a reasonable distance (e.g., `MAX_BUILD_DISTANCE`) of the player's character on the server side before processing the action. Explicitly check input types to prevent crash attempts.

## 2024-05-23 - Missing Server-Side Cost Enforcement
**Vulnerability:** The `BuildingSystem` had the resource cost deduction logic commented out ("Mock"), allowing clients to spawn infinite structures without consuming resources, breaking the survival economy.
**Learning:** "Mock" or "TODO" logic in server-side handlers is a critical risk if it bypasses core validation (like payment/cost), as it enables trivial exploits even if the client UI claims otherwise.
**Prevention:** Never leave cost deduction or security checks mocked in production-path code. Ensure atomic operations where possible (check AND remove) or validate-then-deduct-then-act order to prevent state inconsistencies.
