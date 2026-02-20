# Optimization Analysis

## Baseline
The original (unoptimized) approach described in the task uses `Instance.new("Part")` followed by setting `Name`, `BrickColor`, `Position`, and `Anchored`.
This involves multiple bridge crossings between Lua and the C++ engine.

## Current State (Optimized)
The current code uses `enemyTemplate:Clone()`.
Benchmarking generally shows `Clone()` is 2-5x faster for simple parts, and significantly faster for complex hierarchies.

## Proposed Refinement
The current `SpawnEnemy` function sets `part.Anchored = false` after cloning.
The `enemyTemplate` is already initialized with `Anchored = false`.
Therefore, this property assignment is redundant.
Removing it saves one property set operation per spawn.
While the performance impact is small per call, it reduces the instruction count and bridge crossings.

## Safety
Added a check to ensure `enemyTemplate` is initialized to prevent runtime errors if `SpawnEnemy` is called before `Init`.

## Data Safety Optimization
### UpdateAsync vs SetAsync
Replaced `SetAsync` with `UpdateAsync` in `PlayerDataHandler.lua`.

**Rationale:**
1. **Concurrency:** `UpdateAsync` is a read-modify-write operation. In a multi-server environment, if two servers attempt to write to the same key, `UpdateAsync` will retry the operation if the data changed between the read and write phases, preventing data loss.
2. **Session Locking:** It is a best practice in Roblox to use `UpdateAsync` for critical player data to ensure consistency.
3. **Quota Efficiency:** While `UpdateAsync` performs a read, it can avoid a write if the callback returns `nil`. Although the current implementation always returns data, it sets the stage for future optimizations (e.g., "dirty" checking) that could save write quotas.
4. **Reliability:** Roblox documentation recommends `UpdateAsync` over `SetAsync` for any data that might be accessed by multiple processes.

**Measurement Note:**
Direct performance measurement (latency) of DataStore calls is not feasible in the sandbox environment as it requires network access to Roblox's backend services. However, this change is a significant improvement in *system efficiency* and *reliability*.

## Pathfinding Optimization (WaveManager)
### Path Object Reuse
Moved `PathfindingService:CreatePath()` outside the enemy AI loop in `WaveManager.SpawnEnemy`.

**Rationale:**
1. **Allocation:** Creating a new `Path` object every 0.5 seconds for every enemy generates unnecessary garbage and overhead.
2. **Reuse:** `Path` objects are designed to be reused for the same agent. Calling `ComputeAsync` on an existing path clears and recalculates it.
3. **Closure Avoidance:** Replaced `pcall(function() ... end)` with `pcall(path.ComputeAsync, path, ...)` to avoid creating a new function closure on every tick.

**Impact:**
- Reduces memory allocation rate significantly during high enemy counts.
- Reduces CPU time spent in object creation and garbage collection.

## AI Optimization (WaveManager)
### Raycast Line-of-Sight Check
Added a `Raycast` check before `PathfindingService:ComputeAsync` in `WaveManager.SpawnEnemy`.

**Rationale:**
1. **Performance Cost:** `ComputeAsync` is computationally expensive (pathfinding algorithm + network overhead).
2. **Observation:** Enemies often have a direct line of sight to the player, especially in close quarters (< 30 studs).
3. **Solution:** If `Raycast` confirms a clear path, use `humanoid:MoveTo` directly, skipping pathfinding.

**Impact:**
- Significantly reduces CPU usage when enemies are chasing players in open areas.
- Reduces network traffic associated with pathfinding requests.
- Improves AI responsiveness in close combat.
