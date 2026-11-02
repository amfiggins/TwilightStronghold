# Contributing

## Branches and deploy

- Work lands on `main`, which is also what deploys: every push to `main` publishes to the live Lobby and Survival places (`.github/workflows/publish.yml`). There is no `dev` or `prod` branch yet.
- `lint.yml` runs StyLua, Selene, and the Lune tests on every PR and push to `main`.
- Doc-only pushes can carry `[skip ci]` in the commit message to avoid a publish.
- Many open PRs and short-lived branches come from an external bot (Jules: Bolt for perf, Palette for UX, Sentinel for security). Review them like any other contributor's work before merging.

## Patterns to follow

- **Server authority.** New gameplay actions get a RemoteEvent created in the owning server module, with a rate limit, distance check, NaN checks, and an `ItemDatabase` type check. Copy the pattern from `FarmingSystem.lua` or `CombatSystem.lua`.
- **Data lives in tables, logic lives in systems.** Items, crops, beasts, and sounds are rows in `src/shared/*Database.lua` / `SoundConfig.lua`. Systems read them; they do not hard-code item stats.
- **Survival-only systems** are started from the Survival branch of `ServerMain.server.lua`, and their client scripts no-op in the Lobby.
- **Cleanup on leave.** Per-player state (cooldowns, caches) is cleared in `Players.PlayerRemoving`.
- **Format and lint before pushing.** `stylua src/ tests/`, then `selene src/ tests/` with zero warnings.
- **Tests.** Pure-Lua shared modules get a Lune spec in `tests/lune/` and a line in `runner.luau`.
- **Keep `docs/VISION.md` current.** Any change that adds, removes, or meaningfully changes a system updates its "Current state" section in the same change. Design decisions go in its decision log.

See [`../docs/CONSTRAINTS.md`](../docs/CONSTRAINTS.md) for the rules that cause incidents if broken.

## Where to find things

| Looking for | Where |
|---|---|
| Game design, build state, phase plan, decision log | `docs/VISION.md` |
| Open work | `spec/BACKLOG.md` (summary) and `docs/VISION.md` sections 3 and 4 (detail) |
| Tooling and how to build or test | `docs/DEVELOPMENT.md` |
| Constants, place ids, structure costs | `src/shared/GameConfig.lua` |
| Every RemoteEvent and its handler | `docs/VISION.md` section 2.6 |
| Benchmarks and verify scripts (not shipped) | `dev/` |
| Map authoring | `assets/maps/README.md` |
| Why a piece of code looks odd | `.jules/*.md`, `optimization_notes.md` |
