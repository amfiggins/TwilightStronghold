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
