# Development

## Prerequisites

- [Aftman](https://github.com/LPGhatguy/aftman). It installs the pinned tools from `aftman.toml`: Rojo 7.4.4, Lune 0.10.4, StyLua 2.5.2, Selene 0.31.0.
- Roblox Studio for anything that needs the real engine (playtesting, map authoring, Studio tests).

## Setup

```bash
aftman install
```

## Environment variables

None locally. CI uses:

- Secret `ROBLOX_API_KEY` (Open Cloud key with place publish rights)
- Repo variables `UNIVERSE_ID`, `LOBBY_PLACE_ID`, `SURVIVAL_PLACE_ID`

The place ids are also hard-coded in `GameConfig.PLACE_IDS` and must match.

## Running locally

Build a place file and open it in Studio:

```bash
rojo build default.project.json --output build/twilight-stronghold.rbxl
```

Or run `rojo serve` and connect from the Rojo Studio plugin for live sync. To test the Survival loop inside a non-Survival place, set `GameConfig.IS_SURVIVAL_MODE = true` locally and do not commit it.

## Tests and lint

The same three checks CI runs (`.github/workflows/lint.yml`):

```bash
stylua --check src/ tests/
selene src/ tests/
lune run tests/lune/runner.luau
```

Selene runs with no warnings allowed. Studio integration tests are separate: build `tests.project.json` and press Play in Studio. See `tests/README.md`.

## Environments

There is one: the live Lobby and Survival places. There is no staging place.

## Deploy

Push to `main`. `publish.yml` builds `default.project.json` and POSTs the `.rbxl` to both places as a Published version. It can also be run by hand (`workflow_dispatch`) for one place or both.

As of 2026-11-02 the last three publish runs (May through July 2026) failed at the "Publish to Lobby place" step, so the live places are likely behind `main`. The build step passes; the Open Cloud call is what fails. <!-- TODO: verify cause (expired API key, wrong vars, or place permissions) -->
