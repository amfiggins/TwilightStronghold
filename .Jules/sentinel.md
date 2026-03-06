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

## 2024-05-25 - RemoteEvent Type Confusion

**Vulnerability:** `LoadoutManager` accepted `itemId` from the client without strict type checking. A client sending `false` (boolean) could bypass `if itemId` checks (falsy) while technically providing a non-nil value, leading to unexpected logic paths or state corruption.
**Learning:** Lua's loose typing and falsy nature of `false` can be exploited in RemoteEvents. `if value then` is not the same as `if value ~= nil then`.
**Prevention:** Always explicitly check `typeof(value)` for RemoteEvent arguments, especially when `nil` has a semantic meaning (e.g., "Unequip") distinct from `false` or invalid types.

## 2024-05-25 - Logic Gap: Invalid Item Types in Loadout

**Vulnerability:** The server verified that a player *owned* an item but failed to verify the item's *type* was appropriate for the target slot (e.g., equipping a "Wood Log" as a "Weapon"). This allowed players to create impossible loadouts.
**Learning:** Ownership validation is insufficient; context validation is also required. Just because you have it doesn't mean you can use it *here*.
**Prevention:** Enforce domain-specific constraints (e.g., `item.Type == "Weapon"`) at the entry point of any configuration change (Loadout, Equipment, etc.).

## 2024-05-25 - Unverified Interaction Target (Missing ProximityPrompt Check)

**Vulnerability:** `ResourceManager` accepted any `BasePart` or `Model` in the Workspace as a valid resource node if it was within distance, allowing exploiters to gather/destroy arbitrary map geometry by sending non-interactive parts.
**Learning:** Checking `IsDescendantOf(Workspace)` and distance is insufficient for interaction security. The server must also verify the object has the specific *component* (e.g., `ProximityPrompt`, `ClickDetector`) that designates it as interactable.
**Prevention:** For any interaction claiming to be triggered by a client, explicitly check for the existence and `Enabled` state of the server-side interaction object (e.g., `part:FindFirstChild("Gather"):IsA("ProximityPrompt")`) before processing.

## 2023-10-27 - [MatchmakingService] Fix DoS vulnerability from infinite re-queueing
**Vulnerability:** A critical Denial of Service (DoS) vulnerability existed in `MatchmakingService.lua`. When teleporting players, if a teleport failed, the entire squad was blindly re-queued. If a player had disconnected before or during the teleport, their `Player` object remained in the table without a valid connection (`Parent == nil`), causing consecutive teleport attempts to instantly fail, endlessly re-queueing the squad, and effectively halting the matchmaking server indefinitely.
**Learning:** Asynchronous queues or operations that process player objects across yields (like teleport requests) must explicitly validate the player's connection state to prevent stalling logic with disconnected 'ghost' players.
**Prevention:**
1. Always bind tracking queues to `Players.PlayerRemoving` to maintain state accurately.
2. When performing batch processing on player objects over yielding calls, verify `player and player.Parent ~= nil` before attempting an action or entering a fallback/retry loop.
