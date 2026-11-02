# Backlog

The phase plan in `docs/VISION.md` (section 3) and its ideas list (section 4) hold the detailed game roadmap. This file tracks what is next and anything outside the game plan.

## Next up

- **Phase 4.3, jump-scare encounter.** Beast Hunt state, `BeastJumpScare` remote, camera shake and fog drop, lunge damage unless behind cover.
- **Held-torch repel.** `torch` exists in `ItemDatabase` with `BeastRepel = true`, but nothing emits the repel attribute while it is held. Needs the held-tool system.
- **Studio task: author `assets/maps/ForestKingdom.rbxm`.** `MapManager` already loads it; the map does not exist yet. See `assets/maps/README.md`.
- **Studio task: lobby `SurvivalPortal`** with an `EnterSurvival` prompt, saved as `assets/maps/Lobby.rbxm`.

## Repo and CI

- **Publish is failing.** The last three `publish.yml` runs (2026-05-29, 2026-06-01, 2026-07-29) failed at "Publish to Lobby place". Check that `ROBLOX_API_KEY` is valid and has publish rights on both places, and that `UNIVERSE_ID` / `LOBBY_PLACE_ID` / `SURVIVAL_PLACE_ID` are set.
- **Bot PR backlog.** About 234 open PRs and about 545 remote branches, mostly from the Jules bots. Triage, merge or close, and delete merged branches.
- **Branch layout.** The repo standard is `dev` and `prod` with `prod` as the GitHub default. This repo has only `main`, and `main` deploys. Moving to `dev`/`prod` means updating both workflow triggers and the docs that name `main`.
- **Studio integration tests in CI.** `tests/unit/*.spec.lua` only run in Studio. Options: run-in-roblox on a runner with Studio, or a Lune `@lune/roblox` shim.

## Deferred from earlier phases

- Endless mode after Day 150: flag the run and write the surviving-day count to a leaderboard DataStore (Phase 5/7).
- Structure health and destruction (Phase 5 raids).
