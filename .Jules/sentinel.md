## 2024-05-21 - Trusting Client CFrame
**Vulnerability:** The `BuildingSystem` trusted the client-provided `CFrame` without validating the distance from the player, allowing players to build structures anywhere in the game world (Infinite Reach).
**Learning:** RemoteEvents accepting position data (Vector3, CFrame) are prime targets for exploits if the server assumes the client only sends "valid" or "reachable" coordinates.
**Prevention:** Always validate that the target position of an interaction is within a reasonable distance (e.g., `MAX_BUILD_DISTANCE`) of the player's character on the server side before processing the action. Explicitly check input types to prevent crash attempts.

## 2024-05-22 - Missing Server-Side Validation Logic
**Vulnerability:** The `BuildingSystem` contained commented-out logic for resource deduction, allowing players to build infinitely without cost. The underlying data handler (`PlayerDataHandler`) completely lacked the `RemoveItem` function required to support this validation.
**Learning:** Comments indicating "TODO" or "Mock" logic in critical systems (like economy or inventory) often hide active vulnerabilities where enforcement should be.
**Prevention:** Ensure all critical game actions (buying, building, crafting) have active, server-side validation functions implemented and connected before enabling the feature. Do not leave "mock" logic in production-capable code paths.
