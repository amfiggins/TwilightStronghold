# Constraints

Rules that cause real damage if broken.

## The server is the only authority

Every RemoteEvent handler in `src/server` validates the request: per-player rate limit (`os.clock` cooldown), distance check, NaN/`math.huge` checks on numbers and CFrames, and an `ItemDatabase` type check on any item id. Clients are untrusted. A new remote that skips these is an exploit, not a shortcut. Rate-limit rejections stay silent (no `warn`) so a spamming client cannot flood the server log.

## Changing `GAME_VERSION` resets saved data

DataStore names include the version: `PlayerData_<GAME_VERSION>` and `Structures_v<GAME_VERSION>`. Bumping `GameConfig.GAME_VERSION` points every server at empty stores, so players lose inventory and stats and bases disappear. Only bump it on purpose, with a migration plan if real players exist.

## Do not weaken the player-data session lock

`PlayerDataHandler` uses an `UpdateAsync` compare-and-swap lock (JobId plus timestamp, 600s stale threshold, retries for teleport handoff) and a `BindToClose` flush. These close data-loss windows when players teleport Lobby to Survival. Replacing `UpdateAsync` with `SetAsync`, or removing the flush, brings back item duplication and loss.

## Pushing to `main` publishes the game

`publish.yml` runs on every push to `main` and publishes to both live places. There is no staging place. Anything merged to `main` is what players get. Use `[skip ci]` in the commit message for doc-only pushes if you do not want a publish.

## `dev/` must stay out of the Rojo projects

The benchmarks and verify scripts in `dev/` auto-run when loaded (one creates 10,000 parts, one re-runs `WaveManager.Init()`). They were moved out of `src/server` for that reason (BUG-3 in `VISION.md`). Do not add `dev/` to `default.project.json`.

## Shared modules used by Lune tests must stay Roblox-free

`tests/lune` loads `src/shared` modules under Lune, which has no Roblox globals. That is why `BeastDatabase` stores colours as `{R, G, B}` tables instead of `Color3`. Adding `Color3`, `Vector3`, `Enum`, or `game` to a tested shared module breaks CI.

## Server init order matters

`ServerMain.server.lua` starts systems in a fixed order: `MapManager` before structure restore, `CombatSystem` before `WaveManager`, `BuildingSystem` before `PlotManager`, `DayNightCycle` before `BeastSystem`. The comments there explain each dependency. Reordering causes missing remotes or unwired plots.
