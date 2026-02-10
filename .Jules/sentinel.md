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

## 2024-05-24 - Infinite Resource Node Exploitation

**Vulnerability:** `ResourceManager` validated gathering requests but failed to update the state of the resource node (e.g., destroy or deplete it) after awarding items, allowing players to gather infinitely from a single permanent node.
**Learning:** Validating *access* (distance, cooldown) is not enough; the server must also manage the *lifecycle* of the interactive object to prevent reuse abuse.
**Prevention:** Ensure that successful interactions that yield finite rewards trigger a state change on the server (e.g., `Destroy()`, disabling a `ProximityPrompt`, or setting a depletion flag) to invalidate subsequent requests.

## 2024-05-24 - DoS via Invalid CFrame

**Vulnerability:** The `BuildingSystem` accepted client-provided `CFrame` without validating that its components were finite numbers, allowing attackers to send `NaN` or `Inf` values to crash the server or corrupt the physics engine.
**Learning:** Roblox `CFrame` and `Vector3` types can contain `NaN` (Not a Number) values which bypass standard comparisons (e.g., `NaN > Distance` is false) and propagate through physics calculations.
**Prevention:** Always validate that `Vector3` and `CFrame` inputs from clients contain only finite numbers (`x == x` and `x ~= inf`) before using them in logic or physics.

## 2024-05-25 - Logic Inversion via Negative Numbers

**Vulnerability:** `PlayerDataHandler` functions (`AddItem`, `RemoveItem`, `AddCurrency`) failed to validate that input quantities were positive. This allowed attackers to perform actions like `RemoveItem(..., -10)` to *add* items (logic inversion) or `AddItem(..., -10)` to corrupt inventory states.
**Learning:** Mathematical operations (subtraction/addition) on unvalidated user input can be inverted by negative numbers, completely bypassing intended game logic (e.g., "paying" a negative cost increases balance).
**Prevention:** Always enforce `quantity > 0` checks at the entry point of any function that modifies inventory or currency. Treat "subtract" and "add" as distinct operations that only accept positive magnitudes.
