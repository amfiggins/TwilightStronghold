# Overview

Twilight Stronghold is a cooperative Roblox survival game. Players gather and build by day, survive a stalking biome beast by night, and defend a shared stronghold across many nights. It is a personal project, pre-alpha (`GAME_VERSION = 0.1.0-alpha`).

The full game design, the current build state, and the phased plan live in [`VISION.md`](./VISION.md). This file is the short version.

## How it fits together

- Two Roblox places in one universe: **Lobby** (matchmaking, persistent progression) and **Survival** (the run). Both get the same `.rbxl`; `ServerMain.server.lua` picks which systems to start based on `game.PlaceId` (or `GameConfig.IS_SURVIVAL_MODE` for Studio testing).
- Rojo maps the filesystem into the place (`default.project.json`):
  - `src/shared` to `ReplicatedStorage.Shared`: config and data tables (`GameConfig`, `ItemDatabase`, `CropDatabase`, `BeastDatabase`, `SoundConfig`)
  - `src/server` to `ServerScriptService.Server`: all game logic and every RemoteEvent handler
  - `src/client` to `StarterPlayer.StarterPlayerScripts.Client`: UI, input, audio
  - `assets/maps` to `ServerStorage.Maps`: hand-authored `.rbxm` maps
- Player data and placed structures are saved in Roblox DataStores (`PlayerData_<version>`, `Structures_v<version>`).
- `dev/` holds benchmarks and verify scripts. It is not in any Rojo project, so nothing there ships.
- `tests/` holds Lune unit tests (run in CI) and a Studio-only harness (`tests.project.json`).

## Deploy

`.github/workflows/publish.yml` builds the place with Rojo on every push to `main` and publishes it to both places through the Roblox Open Cloud API. See [`DEVELOPMENT.md`](./DEVELOPMENT.md).

## Related repos

None. This repo is self-contained.

## Other docs

- [`DEVELOPMENT.md`](./DEVELOPMENT.md): tools, build, tests, deploy
- [`CONSTRAINTS.md`](./CONSTRAINTS.md): rules that break things if ignored
- [`../spec/CONTRIBUTING.md`](../spec/CONTRIBUTING.md): how to work in the repo
- [`../spec/BACKLOG.md`](../spec/BACKLOG.md): open work
- `.jules/*.md` and `optimization_notes.md`: historical journals explaining why some code looks the way it does
