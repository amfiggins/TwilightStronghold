# Twilight Stronghold

A cooperative Roblox survival game. Gather and build by day, survive the biome beast by night, defend the stronghold across many nights, and grow the run with farming and progression.

- [`docs/OVERVIEW.md`](./docs/OVERVIEW.md): what it is and how the code fits together
- [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md): tools, build, tests, deploy
- [`docs/VISION.md`](./docs/VISION.md): the full game design, current build state, and phase plan
- [`spec/CONTRIBUTING.md`](./spec/CONTRIBUTING.md): how to work in the repo

## Layout

```
src/shared/   ReplicatedStorage.Shared: GameConfig and data tables
src/server/   ServerScriptService.Server: game logic, datastores, remotes
src/client/   StarterPlayerScripts.Client: UI, input, audio
assets/maps/  ServerStorage.Maps: hand-authored .rbxm maps
dev/          benchmarks and verify scripts (not shipped)
tests/        Lune unit tests (CI) and a Studio-only harness
docs/, spec/  documentation
.jules/       bot journals (perf, UX, security notes)
```

## Quick build

```bash
aftman install
rojo build default.project.json --output build/twilight-stronghold.rbxl
```

Every push to `main` builds this and publishes it to both the Lobby and Survival places.
