## 2024-05-21 - Trusting Client CFrame

**Vulnerability:** The `BuildingSystem` trusted the client-provided `CFrame` without validating the distance from the player, allowing players to build structures anywhere in the game world (Infinite Reach).
**Learning:** RemoteEvents accepting position data (Vector3, CFrame) are prime targets for exploits if the server assumes the client only sends "valid" or "reachable" coordinates.
**Prevention:** Always validate that the target position of an interaction is within a reasonable distance (e.g., `MAX_BUILD_DISTANCE`) of the player's character on the server side before processing the action. Explicitly check input types to prevent crash attempts.

## 2024-05-22 - Infinite Build Exploit (Missing Cost Deduction)

**Vulnerability:** The `BuildingSystem` checked for resource costs in configuration but never actually deducted them from the player's inventory, allowing players to build infinitely without consuming resources (Game Economy Exploit).
**Learning:** "Mock" logic or TODO comments in production-facing code (e.g., `-- In a real scenario, we'd add...`) are dangerous as they can be easily overlooked, leaving critical security gaps.
**Prevention:** Ensure that all actions consuming resources (building, buying, crafting) have an atomic "Check and Deduct" operation enforced on the server before the action is finalized.

## 2024-05-23 - Missing Rate Limiting on Resource Gathering

**Vulnerability:** `ResourceManager` allowed clients to fire `GatherResource` events infinitely fast, bypassing game mechanics and enabling rapid infinite item generation.
**Learning:** Client-side delays (animations, UI) do not constrain exploiters. Every reward-granting RemoteEvent must have a server-side cooldown enforcement.
**Prevention:** Track the last execution timestamp for each player and enforce a `COOLDOWN` threshold on the server. Reject requests that occur too frequently.

## 2024-05-24 - Infinite Resource Farming (Persistence & Deletion)

**Vulnerability:** `ResourceManager` allowed players to gather resources from a node (Tree/Rock) repeatedly without destroying it, and failed to check if the node was still part of the Workspace, enabling infinite farming of a single (or deleted) instance.
**Learning:** Validating input type (`typeof(instance)`) is insufficient; you must also validate the *state* and *location* of the instance (e.g., `IsDescendantOf(Workspace)`). Without server-side depletion (destruction or state change), the economy is vulnerable to simple loop scripts.
**Prevention:** Enforce `IsDescendantOf(game.Workspace)` for all physical interaction targets. Implement explicit resource depletion (e.g., `Destroy()`) on the server side immediately after a successful interaction.
