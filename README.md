# Twilight Stronghold

A cooperative Roblox survival adventure: gather and prepare by day, survive terrifying beasts by night, defend the stronghold across many nights, and grow your run with farming and progression.

## Start here

- 📜 **[`docs/VISION.md`](./docs/VISION.md)** — the living vision and build plan. What the game is, what's built, what's next.
- 🛠 [`aftman.toml`](./aftman.toml) — toolchain (Rojo).
- 🚀 [`.github/workflows/publish.yml`](./.github/workflows/publish.yml) — CI builds the `.rbxl` files and publishes to Roblox via the Open Cloud API.

## Project layout

```
src/
  shared/   # ReplicatedStorage.Shared — GameConfig, ItemDatabase, etc.
  server/   # ServerScriptService.Server — game logic, datastores, security
  client/   # StarterPlayer.StarterPlayerScripts.Client — UI, input, VFX
docs/
  VISION.md # Vision, current state, phased plan, backlog, decision log
.Jules/     # Agent journals (perf, UX, security learnings)
```

## Local build

```bash
aftman install
rojo build default.project.json --output build/twilight-stronghold.rbxl
```

The same `.rbxl` is published to both the Lobby and Survival places. Runtime branching happens in `ServerMain.server.lua` based on `game.PlaceId`. Place-specific content will get its own project file again at Phase 2.1 (see [`docs/VISION.md`](./docs/VISION.md)).

## Updating the vision doc

Every PR that adds, removes, or meaningfully changes a system should update the **Current state** section in [`docs/VISION.md`](./docs/VISION.md). Rules are at the bottom of that file.
