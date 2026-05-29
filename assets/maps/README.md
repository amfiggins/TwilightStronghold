# assets/maps/

Hand-authored Roblox map files (`.rbxm`). Rojo mounts this folder at
`ServerStorage.Maps`, so each `.rbxm` file becomes a child Instance of
`ServerStorage.Maps` with the file's basename as the Instance name.

The server's `MapManager.Init()` looks for `ServerStorage.Maps.ForestKingdom`
on Survival startup and clones it into `workspace.Map`.

## How to author a map

1. Open the synced place in Roblox Studio (via Rojo or by opening a
   freshly-built `.rbxl`).
2. Build your map under any temporary parent in `workspace`. A starter
   layout for the **Forest Kingdom** biome:
   - A clear stronghold pad in the centre (a flat `Part`, large enough
     for 6 players to spawn on)
   - 30+ trees scattered around the perimeter, each named one of:
     `OakTree`, `BirchTree`, `PineTree`, `PalmTree`, `WillowTree`
   - 15+ rock outcrops, each named one of: `Boulder`, `Limestone`,
     `Granite`, `Basalt`
   - 3 ponds, each named `Pond` or `River`
3. Each gather-able node needs a `ProximityPrompt` child named exactly
   `Gather` (case-sensitive — `ResourceManager` checks for it). Set
   `MaxActivationDistance = 8` and `HoldDuration = 0.5` for a good feel.
4. Group everything into a single `Model` named `ForestKingdom`.
5. Right-click the Model → **Save to File** → save as
   `assets/maps/ForestKingdom.rbxm` in this repo.
6. Commit the `.rbxm` file. Rojo will pick it up automatically on the
   next build and it will appear at `ServerStorage.Maps.ForestKingdom`.

## Naming conventions

Node names must match `GameConfig.NodeTypeMapping`. See `src/shared/GameConfig.lua`
for the current list. To add a new variant (e.g., `BlackOakTree`),
add it to `NodeTypeMapping` first.

## Testing in Studio without a saved map

`MapManager.Init()` logs a warning and continues if it can't find a map —
the server still boots normally. So you can keep building game logic
without blocking on the map file.
