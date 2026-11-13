# QA Plan

Twilight Stronghold is a Roblox game. Most of what it does only runs inside the Roblox engine, so most gameplay checks are manual Studio playtests. What an agent can check on its own: the build, the lint and unit tests CI runs, the publish pipeline, and a few repo rules that cause incidents when broken.

There is no dev environment. `main` publishes straight to the live places. "dev" in this plan means the local checkout plus a local Studio build; "prod" means the live Lobby and Survival places.

## Environments

| Env | Base URL / function names | AWS account | External instances | Notes |
|-----|---------------------------|-------------|--------------------|-------|
| dev (local) | `rojo build default.project.json --output build/twilight-stronghold.rbxl`, opened in Roblox Studio | none | none | Pinned tools from `aftman.toml` (Rojo 7.4.4, Lune 0.10.4, StyLua 2.5.2, Selene 0.31.0) |
| prod | Lobby place 140360553864312, Survival place 114856846700519 (one universe) | none | Roblox Open Cloud (publish), Roblox DataStores `PlayerData_<GAME_VERSION>`, `Structures_v<GAME_VERSION>` | Published by `.github/workflows/publish.yml` on push to `main` |

## Test data

- No leads, no email, no messaging. Nothing in this repo sends anything to people.
- Gameplay checks use a Studio Play or Team Test session. Never run gameplay checks in the live places, since their DataStores hold real player data.
- Test recipients: none.

| Fixture | Flow / checks | Env | Records | Setup | Ready |
|---------|---------------|-----|---------|-------|-------|
| F-STUDIO | Every gameplay check (G1 to G10) | dev | A local `.rbxl` built from the checkout, with `IS_SURVIVAL_MODE` set to true locally for the Survival checks (never committed) | Hand step: build, open in Studio, Play. Needs Anthony at the keyboard; an agent cannot drive Studio unattended | no |

## Checks

| Id | Area | What it proves | How to run | Expected | Env | Writes | Nightly |
|----|------|----------------|------------|----------|-----|--------|---------|
| T1 | Lint | Code is formatted | `stylua --check src/ tests/` | exit 0 | dev | none | yes |
| T2 | Lint | No Selene warnings | `selene src/ tests/` | exit 0, 0 warnings | dev | none | yes |
| T3 | Tests | Lune unit tests pass (BeastDatabase, CropDatabase, ItemDatabase, SoundConfig, Vitals, Weapons) | `lune run tests/lune/runner.luau` | exit 0, every spec passes | dev | none | yes |
| T4 | Build | The place builds | `rojo build default.project.json --output <scratch>/ts.rbxl` | exit 0, file written, size over 0 | dev | none | yes |
| T5 | Build | Studio test harness builds | `rojo build tests.project.json --output <scratch>/ts-tests.rbxl` | exit 0 | dev | none | yes |
| C1 | CI | Lint workflow is green on the latest `main` push | `gh run list --workflow lint.yml --branch main --limit 1` | conclusion success for HEAD of `main` | prod | none | yes |
| D1 | Deploy | Latest publish succeeded and matches `main` HEAD | `gh run list --workflow publish.yml --branch main --limit 1` | conclusion success, head sha equals `git rev-parse origin/main` | prod | none | yes |
| D2 | Deploy | Live places were updated after the last publish | Public read: `https://games.roblox.com/v1/games?universeIds=<UNIVERSE_ID>` (no key) | `updated` timestamp is after the last successful publish run | prod | none | yes |
| D3 | Config | Publish config exists and matches the code | `gh variable list` and `gh secret list` (names only) | `UNIVERSE_ID`, `LOBBY_PLACE_ID`, `SURVIVAL_PLACE_ID` vars and `ROBLOX_API_KEY` secret exist; the two place ids equal `GameConfig.PLACE_IDS` | prod | none | yes |
| K1 | Constraint | `dev/` is not shipped | `grep -n '"dev' default.project.json` | no match | dev | none | yes |
| K2 | Constraint | Survival test toggle is off in the committed code | `grep -n "IS_SURVIVAL_MODE =" src/shared/GameConfig.lua` | `= false` | dev | none | yes |
| K3 | Constraint | `GAME_VERSION` did not change by accident | `git log -L '/GAME_VERSION =/,+1:src/shared/GameConfig.lua' --since=<last QA run>` | no change, or a change that `docs/VISION.md` decision log explains | dev | none | yes |
| K4 | Constraint | Tested shared modules stay Roblox-free | `grep -nE "Color3|Vector3|Enum\.|game:|workspace" src/shared/{BeastDatabase,CropDatabase,ItemDatabase,SoundConfig}.lua` | no match (T3 also fails if this breaks) | dev | none | yes |
| K5 | Constraint | Player data still uses the session lock | `grep -n "UpdateAsync\|SetAsync\|BindToClose" src/server/PlayerDataHandler.lua` | `UpdateAsync` and `BindToClose` present, no `SetAsync` on the player store | dev | none | yes |
| K6 | Security | Every client-to-server remote has a rate limit and input checks | For each C→S remote in `docs/VISION.md` section 2.6, open its handler and confirm an `os.clock` cooldown, a distance check where position matters, NaN checks, and an `ItemDatabase` check on item ids | every handler has them | dev | none | yes |
| G1 | Gameplay | Lobby loads and the portal queues a match | Studio Play in Lobby mode: walk into the portal | `JoinQueue` fires, `QueueUpdate` shows the queue size, no output errors | dev | test-data | no |
| G2 | Gameplay | Player data loads and saves | Studio Play with API access on: open inventory, gather one item, stop, Play again | `GetPlayerData` returns the session; the gathered item is still there | dev | test-data | no |
| G3 | Gameplay | Gathering awards resources | Survival mode: gather a tree and a rock | `GatherResource` award notification, inventory count goes up | dev | test-data | no |
| G4 | Gameplay | Building places a structure and it persists | Survival mode: place a wall and a tower, restart | `PlaceStructure` builds both; structures restore from `Structures_v<version>` | dev | test-data | no |
| G5 | Gameplay | Combat hits a target | Survival mode: equip a weapon, attack an enemy | `Attack` lands damage; out-of-range or NaN attack is rejected silently | dev | test-data | no |
| G6 | Gameplay | Eating and drinking restore vitals | Survival mode: eat a food item and drink a drink item | `VitalsUpdate` shows Hunger and Thirst going up; the item is removed | dev | test-data | no |
| G7 | Gameplay | Farming plant, water, harvest | Survival mode: plant a seed on a tilled plot, water it, wait, harvest | each step fires its remote; harvest awards the crop yield and resets the plot | dev | test-data | no |
| G8 | Gameplay | Day and night cycle runs | Survival mode: wait through one phase change | `PhaseChanged` fires with the next phase and day count; HUD timer updates | dev | none | no |
| G9 | Gameplay | Beast stalks at night | Survival mode at night | `BeastNearby` tiers change as the beast approaches, no more than twice a second; audio cues play | dev | none | no |
| G10 | Gameplay | Loadout equips | Lobby: equip a weapon, base kit, and bag | `SetLoadout` updates the loadout UI and saves it | dev | test-data | no |
| G11 | Gameplay | Waves spawn | Survival mode at night | `WaveManager` spawns enemies that path to the stronghold; no output errors | dev | none | no |

Gameplay checks are Nightly: no because they need Studio and a person. Their writes go only to Studio's local test DataStores.

## Coverage

| Job or entry point | Checks |
|--------------------|--------|
| Build and ship the game to both places | T4, C1, D1, D2, D3 |
| Keep code clean and tested | T1, T2, T3, T5 |
| Matchmaking in the Lobby (`JoinQueue`, `QueueUpdate`) | G1 |
| Persistent player data (`GetPlayerData`, session lock) | G2, K5 |
| Gather (`GatherResource`) | G3 |
| Build and persist structures (`PlaceStructure`) | G4 |
| Combat (`Attack`) | G5, K6 |
| Vitals (`EatItem`, `DrinkItem`, `VitalsUpdate`) | G6, K6 |
| Farming (`PlantSeed`, `WaterCrop`, `HarvestCrop`) | G7, K6 |
| Day and night (`PhaseChanged`, `Day150Reached`) | G8 |
| Beast (`BeastNearby`) | G9 |
| Loadout (`SetLoadout`) | G10 |
| Night waves (`WaveManager`) | G11 |
| Keep saved data safe (`GAME_VERSION`, session lock) | K3, K5 |
| Repo rules (`dev/` not shipped, Roblox-free shared modules, test toggle off) | K1, K2, K4 |

## Gaps

- `Day150Reached` has no practical check: reaching day 150 in a playtest is not realistic. It would need a debug hook to jump the day counter.
- Every gameplay check (G1 to G11) needs Roblox Studio and a person, so none can run unattended. F-STUDIO stays `Ready: no`.
- Lobby to Survival teleport (the session-lock handoff) only works in the live universe, not in a single Studio place. K5 checks the code; there is no live check, because the only live places hold real player data.
- D1 is expected to fail today: the last three publish runs (May to July 2026) failed at "Publish to Lobby place". That is a known issue in `docs/DEVELOPMENT.md`, not a QA plan problem.
- No staging place exists, so there is no way to check a publish before players get it.
