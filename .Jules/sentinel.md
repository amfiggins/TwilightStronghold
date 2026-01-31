## 2024-05-21 - Trusting Client CFrame
**Vulnerability:** The `BuildingSystem` trusted the client-provided `CFrame` without validating the distance from the player, allowing players to build structures anywhere in the game world (Infinite Reach).
**Learning:** RemoteEvents accepting position data (Vector3, CFrame) are prime targets for exploits if the server assumes the client only sends "valid" or "reachable" coordinates.
**Prevention:** Always validate that the target position of an interaction is within a reasonable distance (e.g., `MAX_BUILD_DISTANCE`) of the player's character on the server side before processing the action. Explicitly check input types to prevent crash attempts.
