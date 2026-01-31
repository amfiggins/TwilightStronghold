## 2024-05-21 - Trusting Client CFrame
**Vulnerability:** The `BuildingSystem` trusted the client-provided `CFrame` without validating the distance from the player, allowing players to build structures anywhere in the game world (Infinite Reach).
**Learning:** RemoteEvents accepting position data (Vector3, CFrame) are prime targets for exploits if the server assumes the client only sends "valid" or "reachable" coordinates.
**Prevention:** Always validate that the target position of an interaction is within a reasonable distance (e.g., `MAX_BUILD_DISTANCE`) of the player's character on the server side before processing the action. Explicitly check input types to prevent crash attempts.

## 2024-05-22 - Infinite Build Exploit (Missing Cost Deduction)
**Vulnerability:** The `BuildingSystem` checked for resource costs in configuration but never actually deducted them from the player's inventory, allowing players to build infinitely without consuming resources (Game Economy Exploit).
**Learning:** "Mock" logic or TODO comments in production-facing code (e.g., `-- In a real scenario, we'd add...`) are dangerous as they can be easily overlooked, leaving critical security gaps.
**Prevention:** Ensure that all actions consuming resources (building, buying, crafting) have an atomic "Check and Deduct" operation enforced on the server before the action is finalized.
