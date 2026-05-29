# Twilight Stronghold — Vision & Build Plan

**Living document.** This is the single source of truth for what Twilight Stronghold is, what we have built, and what is left to build. Keep it current.

- **Status:** Pre-alpha (`GAME_VERSION = 0.1.0-alpha`)
- **Last updated:** 2026-05-28 (Phase 0 in progress)
- **Owners:** @amfiggins
- **Update rules:** see [How to keep this doc alive](#how-to-keep-this-doc-alive) at the bottom.

---

## Table of contents

1. [The vision](#1-the-vision)
2. [Current state of the build](#2-current-state-of-the-build)
3. [Phased build plan](#3-phased-build-plan)
4. [Backlog & ideas](#4-backlog--ideas)
5. [Decision log](#5-decision-log)
6. [How to keep this doc alive](#how-to-keep-this-doc-alive)

---

# 1. The vision

## 1.1 Game overview

Twilight Stronghold is a cooperative Roblox survival adventure that combines:

- Survival and base defense
- Exploration and gathering
- Horror-inspired nighttime survival
- Persistent role progression
- Randomized, replayable runs

Players prepare in a persistent lobby world, then enter a randomized biome where they must survive increasingly difficult nights while upgrading a shared stronghold, rescuing survivors, gathering resources, and avoiding terrifying biome beasts that stalk the darkness.

The game is designed for **replayability, co-op teamwork, progression, and memorable panic moments** during nighttime survival.

**Identity statement:** _Co-op fantasy survival with terrifying nighttime beast encounters._

## 1.2 Core gameplay loop

### Daytime loop

During the day players:

- Explore the biome
- Gather resources (fish, mine ore, chop wood, hunt animals, herbs)
- Complete quests
- Rescue stronghold residents (NPCs)
- Find hidden caves and dungeons
- Upgrade defenses, build structures, craft tools and weapons
- Farm crops at the stronghold

Daytime focus: **progression, exploration, preparation.**

### Nighttime loop

At night:

- Beasts roam the map; visibility drops
- Players are pressured to return home
- Raids may attack the stronghold
- Special events can occur
- The stronghold light becomes critical
- Players caught too far from safety risk being hunted by the biome beast

Nighttime should feel: **stressful, suspenseful, atmospheric, dangerous, unpredictable.**

## 1.3 Match structure

| Property | Value |
|---|---|
| Players per run | Up to **6** (cooperative; no PvP at launch) |
| Average successful run length | 2+ hours |
| Day 150 milestone | Survive **150 nights** to unlock endless leaderboard ranking. Run does not end — players keep going. |
| Endless mode | After Day 150, difficulty continues scaling and players compete on a survival-rank leaderboard. |
| Joining mid-run | Friends may join if a reserved slot exists; reserved slots cannot be filled by strangers |

## 1.4 Lobby world

The lobby is a persistent progression world (separate Roblox place from Survival).

Players in the lobby can:

- Fish, gather, mine, farm, trade
- Complete progression tasks
- Buy cosmetics, unlock classes
- Upgrade tools, unlock mounts and pets
- Customize stronghold visuals
- Travel via teleport points / portals

## 1.5 Launch biomes

Three biomes at launch, chosen for asset reusability and clear themes.

### 1.5.1 Forest Kingdom

- **Stronghold theme:** stone woodland castle
- **Resources:** wood, berries, fish, iron ore, herbs
- **Main beast:** Wendigo
- **Atmosphere:** dense fog, dark woods, glowing eyes in trees, snapping branches, distant screams

### 1.5.2 Frozen Tundra

- **Stronghold theme:** ice fortress
- **Resources:** ice ore, frozen fish, crystal deposits, fur animals
- **Main beast:** Yeti
- **Atmosphere:** snowstorms, low visibility, frozen lakes, howling winds, giant footprints

### 1.5.3 Desert Sultanate

- **Stronghold theme:** Arabian palace fortress
- **Resources:** sandstone, oasis fish, rare gems, desert herbs
- **Main beast:** Djinn Stalker
- **Atmosphere:** sandstorms, whispers in dunes, mirages, glowing eyes in storms, shifting ruins

## 1.6 Beast system

### Design philosophy

The beast is not just an enemy. It is a fear mechanic, a pressure mechanic, a map-control mechanic, and a nighttime survival mechanic. The beast creates tension and forces players to respect the night.

### Beast behavior on most nights

- Roams the map
- Stalks players
- Avoids strong light
- Hunts isolated players
- Appears unpredictably

### Horror mechanics

The beast is usually **heard before seen**. Partial reveals and audio cues are the heart of the tension:

- Footsteps, growls, breathing
- Snapping branches
- Distorted whispers
- Glimpses through fog or trees
- Brief flashes during lightning or torchlight

### Jump-scare encounters

If players linger outside too long, the beast may suddenly appear nearby. The cue stack:

1. Camera shake
2. Audio intensifies
3. Chase music begins
4. Player must escape

Player escape options: run, weave through terrain, use portable lights, hide behind obstacles, return to stronghold safety.

### Portable light vs stronghold light

| Source | Effect |
|---|---|
| Torches, lanterns, magical lights (carried) | Briefly stun the beast and create escape windows |
| Stronghold main light | Stronger light = farther beast distance and easier nighttime defense |

Raiders prioritize **damaging light structures** to weaken the safe zone.

## 1.7 Sub-beasts

Each run has 1 biome main beast + 1 random sub-beast pulled from a global pool.

Sub-beast pool:

- Shadow Hound
- Nightcrawler
- Mimic Beast
- Hollow Watcher
- Bone Stalker
- Screaming Widow
- Lantern Thief
- Fog Wraith

## 1.8 Stronghold residents (NPCs)

- Each run spawns 6 random residents (rare residents have lower spawn rates)
- Residents live inside the stronghold; require beds/housing
- Unlock automation, upgrades, and bonuses
- **Residents cannot die.** During attacks, they hide in assigned shelters

Naming: "**Residents**" is the launch term. Alternates considered: survivors, settlers, refugees, villagers, companions.

## 1.9 Roles (classes)

### Launch roles

- Hunter
- Fisherman
- Builder
- Warrior
- Miner
- Explorer

### Future roles

- Beast Tamer
- Mage
- Engineer
- Medic
- Alchemist
- Gunslinger
- Shaman
- Rogue

## 1.10 Combat philosophy

Combat should be **accessible, readable, fun in groups, not overly technical.**

Avoid: complex parry systems, soulslike combat, high mechanical skill barriers.

Focus on: teamwork, positioning, class identity, preparation, progression.

## 1.11 Stronghold upgrade tiers

| Tier | Unlocks |
|---|---|
| 1 (MVP) | Walls, gates, light source, crafting station, beds, storage, watchtower |
| 2 | Traps, farms, forge, healing station, guard NPCs |
| 3 | Magic defenses, siege weapons, advanced automation, portal systems |

## 1.12 Raid design

- **Major raids** every 5 nights
- **Special events:** Blood Moon, Eclipse Night, Beast Frenzy, Fog Night, Corrupted Storm
- **Scaling:** based on the current night number only (so preparation matters; skill is rewarded; weak prep is punishing)

## 1.13 Progression philosophy

Reward casual players, dedicated grinders, collectors, explorers, and completionists. Progression should feel meaningful, achievable, long-term, and replayable.

## 1.14 Monetization philosophy

| Allowed | Avoid |
|---|---|
| Cosmetics, convenience, pets, mounts | Heavy pay-to-win |
| Premium classes | Stat purchasing |
| Private servers | Unavoidable monetization pressure |

## 1.15 MVP focus

Balanced mix of: exploration, survival, gathering, stronghold defense, horror tension, replayability.

## 1.16 Long-term expansions

**Additional biomes:** Volcano Realm, Swamp Kingdom, Jungle Temple, Ocean Isles, Haunted Graveyard, Alien World, Mushroom Caverns

**Future systems:** persistent world mode, cross-biome expeditions, guild strongholds, seasonal world events, world bosses, advanced professions, beast corruption events, legendary resident NPCs, biome-specific mounts, procedural dungeon generation.

## 1.17 Core emotional experience

| Time | Should feel like |
|---|---|
| Daytime | Adventurous, productive, curious, cooperative |
| Nighttime | Nervous, hunted, vulnerable, desperate, relieved when safe |

The strongest moments should happen when:

- Players barely escape the beast
- The light is failing
- The stronghold is under attack
- Friends are trying to survive together at night



---

# 2. Current state of the build

This section reflects what is **actually in the repo** as of the last update. Update it whenever a system lands or changes meaningfully.

## 2.1 Tooling, project, and CI

| Area | State |
|---|---|
| Toolchain | `aftman.toml` pins `rojo-rbx/rojo@7.4.4`, `JohnnyMorganz/StyLua@2.5.2`, `Kampfkarren/selene@0.31.0`, `lune-org/lune@0.10.4`. No Wally / TestEZ proper yet. |
| Project files | Single `default.project.json` mapping `src/shared` → `ReplicatedStorage.Shared`, `src/server` → `ServerScriptService.Server`, `assets/maps` → `ServerStorage.Maps`, `src/client` → `StarterPlayer.StarterPlayerScripts.Client`. CI publishes the same `.rbxl` to both Lobby and Survival Place IDs; runtime branching happens via `game.PlaceId` in `ServerMain.server.lua`. We'll split the project file once the Lobby and Survival places ship genuinely different content. |
| Place IDs | Lobby `140360553864312`, Survival `114856846700519` (in `GameConfig.PLACE_IDS`). |
| CI | `.github/workflows/publish.yml` builds one `.rbxl` with Rojo on push to `main`, then POSTs it to both Lobby and Survival places via the Roblox Open Cloud Places API using `secrets.ROBLOX_API_KEY` and the GitHub repo vars `UNIVERSE_ID`, `LOBBY_PLACE_ID`, `SURVIVAL_PLACE_ID`. `.github/workflows/lint.yml` runs `stylua --check`, `selene` (no warnings), and `lune run tests/lune/runner.luau` on every PR and push to `main`. |
| `.luau-analyze.json` | Globals list for local Luau analysis only; not in CI. |
| `.Jules/*.md` | Three personality journals (`bolt`, `palette`, `sentinel`) used by an external agent system to log perf/UX/security learnings. Treat as a changelog of "why this code looks the way it does." |

## 2.2 Server systems (`src/server/`)

| File | What it does | Status |
|---|---|---|
| `ServerMain.server.lua` | Entry point. Loads PlayerData/Resource/Loadout always; branches on PlaceId or `IS_SURVIVAL_MODE` to load DayNight/Wave/Building (Survival) or Matchmaking (Lobby). | ✅ Real |
| `PlayerDataHandler.lua` | DataStore-backed player data. Schema: `Stats {Rubies, Diamonds, Level, XP}`, `Inventory[]`, `Loadout {Weapon, BaseKit, Bag}`, `CodesRedeemed`. O(1) inventory lookup, swap-remove, NaN/`math.huge` validation, retry-with-backoff `GetAsync`, staggered autosave (60s window divided across players). | ✅ Mature |
| `ResourceManager.lua` | `GatherResource` RemoteEvent handler. Validates rate limit (1s), distance (25 studs²), proximity prompt presence, maps node names to resource IDs via `NodeTypeMapping`, rolls rare drops, awards items, schedules respawn via `ResourceRespawn` if `DestroyOnGather`. | ✅ Real |
| `ResourceRespawn.lua` | Snapshots gathered nodes into `ServerStorage.ResourceRespawnPool` and re-parents them back at the original CFrame 60–120s later. | ✅ Real (Phase 2.2) |
| `BuildingSystem.lua` | `PlaceStructure` RemoteEvent. Rate limit (0.5s), NaN-CFrame validation, 20-stud range, `OverlapParams` collision check, deducts wood, instantiates Part under `workspace.PlayerStructures`, tags with `TwilightStronghold_PlayerStructure`, persists via `StructurePersistence`. | ✅ Real |
| `StructurePersistence.lua` | Per-Place DataStore. AddStructure() appends to in-memory list and schedules a debounced (5s) save. On Survival start, loads saved records and re-instantiates each via a renderer callback. BindToClose final flush. | ✅ Real (Phase 2.3) |
| `DayNightCycle.lua` | 1Hz tick. Day=300s, Night=120s. Fires `PhaseChanged` to clients. Calls `WaveManager.StartWave` on night start. Sets `Lighting.ClockTime` only. | 🟡 Basic |
| `WaveManager.lua` | Spawns enemies during night, deals touch damage with per-player cooldown, despawns at dawn, registers/unregisters with `CombatSystem`. Pathfinding+raycast LOS shortcut, tiered update rates. | 🟡 Single enemy type |
| `LoadoutManager.lua` | `SetLoadout` RemoteEvent. Validates slot, type-checks itemId against `ItemDatabase`, enforces type per slot, rate-limits. | 🟡 (see bug list) |
| `CombatSystem.lua` | `Attack` RemoteEvent. Validates equipped weapon, target is a registered enemy, range/cooldown. Tracks per-player damage contribution; awards proportional Rubies + XP on kill via `UnregisterEnemy`. | ✅ Real (Phase 1.1) |
| `VitalsSystem.lua` | `EatItem` + `DrinkItem` + `VitalsUpdate` RemoteEvents. Staggered decay loop (Hunger −1/tick, Thirst −2/tick every 5s). Starvation/dehydration damage when either hits 0. Delegates consume logic to `PlayerDataHandler.ConsumeItem`. | ✅ Real (Phase 1.2) |
| `MapManager.lua` | On Survival start, clones `ServerStorage.Maps.ForestKingdom` into `workspace.Map`. Counts gather-able nodes. Logs a warning and continues if the map is missing. | ✅ Real (Phase 2.1) |
| `MatchmakingService.lua` | `JoinQueue` + `QueueUpdate` RemoteEvents. FIFO, 6 players → `TeleportAsync` to Survival with a `MatchId` GUID. Re-queues on teleport failure (ghost-cleanup). | ✅ Real |
| `BuildingSystemTest.lua` | Module that mocks a player and asserts a Wall is created. Not auto-run, must be required from the command bar. | 🟡 Ad-hoc |
| `VerifyResourceMappings.server.lua` | Iterates `NodeTypeMapping`, warns on unmapped resources. | ⚠️ Auto-runs in production |
| `VerifyWaveManager.server.lua` | Re-runs `WaveManager.Init()` (duplicate of ServerMain), asserts shape. | ⚠️ Auto-runs in production |
| `EnemySpawnBenchmark.lua` | Allocates/destroys 10,000 parts. | ⚠️ Auto-runs in production |
| `QueueBenchmark.lua` | 100-iteration queue benchmark. | ⚠️ Auto-runs in production |
| `InventoryBenchmark.lua`, `PathfindingBenchmark.lua`, `RetryBenchmark.lua` | Module benchmarks. | 🟡 Manual only |

## 2.3 Client systems (`src/client/`)

| File | What it does | Status |
|---|---|---|
| `InteractionClient.client.lua` | Listens for `Gather` proximity prompts → starts minigame → fires `GatherResource` to server on success. Toast notifications on award. | ✅ Real |
| `CombatClient.client.lua` | Survival-only. On M1 / gamepad R2, picks the model under the cursor and fires `Attack`. Server validates everything. No-ops in Lobby. | ✅ Real (Phase 1.1) |
| `BuildPlacementClient.client.lua` | Survival-only. Press `B` to toggle build mode; `1`/`2` to pick Wall/Tower; mouse moves a translucent ghost; click fires `PlaceStructure`. Ghost is green when valid, red when out of range / colliding (mirrors server checks). | ✅ Real (Phase 2.4) |
| `MinigameController.lua` | "Fisch-style" hold-to-align minigame. Multi-input (keyboard / mouse / touch / gamepad). Recently improved with success-state delay, platform-aware hints, gamepad cache. | 🟡 Single static minigame |
| `LoadoutUI.client.lua` | Always-visible left-side panel listing Weapons / Kits / Bags from inventory. Equip/unequip with rarity colors and tooltips. | 🟡 (Bag-equip broken — see bugs) |
| `PortalController.client.lua` | Lobby-only. Listens for `EnterSurvival` prompt → fires `JoinQueue`. Toast on queue update. | ✅ Real |

## 2.4 Shared modules (`src/shared/`)

### `GameConfig.lua`

Constants: `GAME_VERSION`, `IS_SURVIVAL_MODE`, `MAX_LOBBY_PLAYERS = 20`, `MAX_SESSION_PLAYERS = 4`, `INVENTORY_CAPACITY = 5`, `MAX_BUILD_DISTANCE = 20`, `PLACE_IDS`, `StructureCosts {Wall, Tower}`, `StructureProperties` (Wall and Tower share identical 4×8×1 brown-Part geometry — clear bug), `Rarity` (Common→Mythic with Color3 + Chance), `Resources {Tree, Rock, Lake}`, `NodeTypeMapping`.

> Note: vision says **6 players per run**. Code currently says `MAX_SESSION_PLAYERS = 4`. **Decision needed** — see [Decision log](#5-decision-log).

### `ItemDatabase.lua`

13 items in 5 categories: Tool (`wooden_rod`, `iron_pickaxe`), Weapon (`wooden_sword`, `void_sword`), Kit (`watchtower_kit`), Bag (`starter_bag`/`leather_bag`/`reinforced_bag`), Material (`wood_log`, `golden_wood`, `stone_ore`), Consumable (`raw_fish`).

Weapons declare `Damage`, `Range`, `Cooldown` (used by `CombatSystem`).

**Missing categories** for the vision: Food (with Hunger value), Seed, Crop, Furniture, LightSource, Trap, Resident-bonus item, Quest item.

## 2.5 Cross-cutting feature scorecard

Legend: ✅ implemented · 🟡 partial · ❌ missing

| Feature | Status | Notes |
|---|---|---|
| Day/Night cycle | 🟡 | Basic; Day 150 milestone event fires; no countdown HUD _(wait, HUD landed in Phase 1.3 — see below)_ |
| Resource gathering (wood/stone/fish) | ✅ | Solid security model; nodes respawn 60–120s after gather (Phase 2.2) |
| Building system | 🟡 | Wall/Tower placements with collision check + persistence; client-side ghost preview with green/red feedback before clicking. Tagged `TwilightStronghold_PlayerStructure` for future raid AI. Still missing: health/damage, destruction. |
| Inventory | ✅ | O(1) lookup, bag capacity, swap-remove |
| Loadout | 🟡 | Weapon/Kit work; **Bag-equip broken** end-to-end |
| Combat | ✅ | Server-authoritative `CombatSystem`: weapon-equipped check, range + cooldown, damage application, proportional Ruby/XP rewards on kill |
| Enemies / waves | 🟡 | One enemy type, deals touch damage, despawns at dawn, drops rewards. Still missing: ranged enemies, multiple types, despawn at >150 stud distance, AI attack animations |
| Matchmaking | ✅ | 4-player queue; ghost cleanup |
| DataStore persistence | ✅ | Solid retries; **no `BindToClose`, no cross-server session lock** |
| HUD | ✅ | `SurvivalHUD.client.lua`: Health/Hunger/Thirst bars (bottom-left) + Day/Night phase label + countdown timer (top-center) + Day 150 milestone banner |
| Hunger / Thirst / Cold | ✅ | `Stats.Hunger` and `Stats.Thirst` in DEFAULT_DATA; `VitalsSystem` decays both every 5s; starvation/dehydration damage when either hits 0; `EatItem`/`DrinkItem` RemoteEvents |
| Hotbar | ❌ | Loadout panel exists; no number-key hotbar |
| Farming | ❌ | Zero — no seeds, plots, growth, watering, harvest |
| Crafting | ❌ | No `CraftingManager`, no recipes, no workbench |
| Map / world generation | 🟡 | `MapManager` clones `ServerStorage.Maps.ForestKingdom` into `workspace.Map` on Survival start. Map authoring (`ForestKingdom.rbxm`) is a Studio task — see `assets/maps/README.md`. |
| Audio | ❌ | Zero `SoundService` usage |
| VFX | 🟡 | TweenService for enemy fade and UI tweens only |
| Beast system (the vision pillar) | ❌ | None |
| Sub-beasts | ❌ | None |
| Stronghold light system | ❌ | None |
| Residents (NPCs) | ❌ | None |
| Roles / classes | ❌ | None |
| Raids / blood-moon events | ❌ | None |
| Day 150 milestone | 🟡 | `Day150Reached` RemoteEvent fires + client banner; leaderboard DataStore write deferred to Phase 5/7 |

## 2.6 Network surface (RemoteEvents / RemoteFunctions)

All under `ReplicatedStorage.Remotes`:

| Name | Type | Created in | Direction | Purpose |
|---|---|---|---|---|
| `GetPlayerData` | RemoteFunction | `PlayerDataHandler` | C→S | Fetch player session data (rate-limited) |
| `GatherResource` | RemoteEvent | `ResourceManager` | both | Request gather; receive award notification |
| `PlaceStructure` | RemoteEvent | `BuildingSystem` (Survival only) | C→S | Build wall/tower at CFrame |
| `Attack` | RemoteEvent | `CombatSystem` (Survival only) | C→S | Attack a target Model with the equipped weapon |
| `EatItem` | RemoteEvent | `VitalsSystem` (Survival only) | C→S | Consume a Food item; server validates, removes, applies HungerRestore |
| `DrinkItem` | RemoteEvent | `VitalsSystem` (Survival only) | C→S | Consume a Drink item; server validates, removes, applies ThirstRestore |
| `VitalsUpdate` | RemoteEvent | `VitalsSystem` (Survival only) | S→C | `{Hunger, Thirst, MaxHunger, MaxThirst}` snapshot on every change |
| `SetLoadout` | RemoteEvent | `LoadoutManager` | C→S | Equip/unequip Weapon or BaseKit |
| `JoinQueue` | RemoteEvent | `MatchmakingService` (Lobby only) | C→S | Enter matchmaking queue |
| `QueueUpdate` | RemoteEvent | `MatchmakingService` (Lobby only) | S→C | Notify queue join/leave + size |
| `PhaseChanged` | RemoteEvent | `DayNightCycle` (Survival only) | S→All | `(phase, dayCount, timeRemaining)` |

**Conventions used:** per-user `os.clock` cooldown; silent rate-limit failures (no `warn` to prevent log-flood DoS); type-check itemId against `ItemDatabase` to prevent type-confusion exploits; cleanup in `Players.PlayerRemoving`.

## 2.7 Known bugs & risks

Tagged so we can sweep them as a batch.

| # | Severity | Issue |
|---|---|---|
| BUG-1 | High | ~~`LoadoutUI.client.lua` sends `slot = "Bag"` but `LoadoutManager` only allows `Weapon`/`BaseKit` → bag equipping is dead-on-arrival.~~ **Fixed** in Phase 0 (LoadoutManager now accepts `"Bag"` with `Type=="Bag"` enforcement). |
| BUG-2 | Medium | ~~`DayNightCycle.StartDay` increments `DayCount` on every call, including initial `Init`. First print is "Day 2 Started."~~ **Fixed** in Phase 0 (`DayCount` starts at 0). |
| BUG-3 | High | ~~`Verify*.server.lua` and `EnemySpawnBenchmark.lua` / `QueueBenchmark.lua` auto-run in production, including a duplicate `WaveManager.Init()`. Burns startup time and creates 10k parts.~~ **Fixed** in Phase 0 (moved to top-level `dev/` folder which Rojo does not sync). |
| BUG-4 | High | ~~`PlayerDataHandler` has no `game:BindToClose` final flush — in-flight saves are dropped on shutdown.~~ **Fixed** in Phase 0 (BindToClose flushes all sessions in parallel with a 25s budget; skipped in Studio). |
| BUG-5 | High | ~~No cross-server session lock — two servers can read/write the same player key during teleport handoff.~~ **Fixed** in Phase 0 (compare-and-swap session lock via `UpdateAsync` with 600s stale threshold and 5×6s teleport-handoff retries). |
| BUG-6 | High | ~~Resource nodes never respawn after gather. Empty world after a few minutes.~~ **Fixed** in Phase 2.2 (`ResourceRespawn` snapshots gathered nodes into a holding folder, then re-parents them after 60–120s; preserves full hierarchy). |
| BUG-7 | High | ~~Built structures never persist across server restarts.~~ **Fixed** in Phase 2.3 (`StructurePersistence` saves placements to a per-Place DataStore with 5s debounce + BindToClose flush, restores on Survival server start). |
| BUG-8 | Critical-for-game | ~~Enemies cause no damage. Players cause no damage to enemies.~~ **Fixed** in Phase 1.1 (server-authoritative `CombatSystem` with weapon validation + range + cooldown; enemies deal touch damage with per-player cooldown; kill rewards split by damage contribution). |
| BUG-9 | Low | ~~`survival.project.json` is byte-identical to `default.project.json` — pointless duplication.~~ **Fixed** in Phase 0 (deleted; CI builds once and publishes the same `.rbxl` to both Place IDs. Will reintroduce a differentiated project at Phase 2.1 when we add a real Forest Kingdom map). |
| BUG-10 | Low | ~~Tower has Wall dimensions (`4,8,1`) and same color.~~ **Fixed** in Phase 0 (Tower is now `4×16×4` with darker color). |
| BUG-11 | Low | ~~`WaveManager.StartWave` checks `Phase ~= "Night"` only after `task.wait(SPAWN_RATE)` — small window where a post-dawn enemy spawns.~~ **Fixed** in Phase 1.1 (loop waits in 0.5s slices and re-checks the phase before spawning). |
| BUG-12 | Low | ~~`MinigameController.target` is static at `0.5` — sine wave is commented out, so the minigame is trivially solvable.~~ **Fixed** in cleanup pass (target oscillates with a 5s sine wave; per-game phase via `gameStartTime`). |
| BUG-13 | Medium | ~~`BuildingSystem.PlaceStructure` has a literal `-- Ensure no collision` TODO and no implementation. Walls can stack inside each other or terrain.~~ **Fixed** in Phase 2.3 (`hasCollision` uses `OverlapParams` + `workspace:GetPartBoundsInBox`, ignores the placer's own character). |
| BUG-14 | Low | ~~`raw_fish` is a Consumable but has no Hunger/Heal value, and no eat handler exists.~~ **Fixed** in Phase 1.2 (`raw_fish` is now `Type Food` with `HungerRestore = 10`; `EatItem`/`DrinkItem` RemoteEvents wired through `VitalsSystem` → `PlayerDataHandler.ConsumeItem`). |
| BUG-15 | Low | ~~No StyLua/Selene config; style is loose.~~ **Fixed** in Phase 0 + cleanup pass: StyLua 2.5.2 + Selene 0.31.0 pinned in `aftman.toml`; configs at `stylua.toml` and `selene.toml`; CI runs `stylua --check` and `selene` (no `--allow-warnings`) on every PR via `.github/workflows/lint.yml`. All 24 historical warnings resolved. |
| BUG-16 | Low | ~~No automated test harness; `BuildingSystemTest.lua` and benchmarks are ad-hoc.~~ **Fixed** in cleanup pass. CI runs `lune run tests/lune/runner.luau` on every PR via `.github/workflows/lint.yml` (separate `test` job). 10 tests cover ItemDatabase, weapon definitions, and food/drink items. Studio runtime integration tests under `tests/unit/*.spec.lua` and the `TestFramework.lua` harness remain as scaffolding for future tests that need Roblox APIs. |
| BUG-17 | Low | ~~`LoadoutUI` is always visible — no toggle key.~~ **Fixed** in Phase 1.3 (starts hidden; `Tab` / DPad-Down toggles; populates lazily on first open). |



---

# 3. Phased build plan

This plan sequences work so each phase produces a **playable, demonstrable build**, even if the game isn't done. Each phase has a **definition of done** so we know when to move on. Track items by editing the checkboxes here.

> **How to read each task:** each task lists either a file path to create/modify, the user-facing change, or both. Tasks tagged `[BUG-N]` fix one of the bugs in §2.7.

## Phase 0 — Foundation cleanup

**Goal:** stop the bleeding before adding more features. Fix dead-on-arrival bugs and remove production hazards. Unlocks confident development on top.

**DoD:** A fresh server start has no auto-running benchmarks, all known data-loss windows are closed, and equipping a Bag actually works.

- [x] Move `BuildingSystemTest.lua`, `EnemySpawnBenchmark.lua`, `InventoryBenchmark.lua`, `PathfindingBenchmark.lua`, `QueueBenchmark.lua`, `RetryBenchmark.lua`, `VerifyResourceMappings.server.lua`, `VerifyWaveManager.server.lua` out of `src/server/` into `dev/` (top-level, not synced by Rojo). [BUG-3]
- [x] Add `game:BindToClose(function() ... save all sessions ... end)` to `PlayerDataHandler.Init`. Iterate `Players:GetPlayers()`, fire `Save` on each, wait up to ~25s. [BUG-4]
- [x] Implement cross-server session lock in `PlayerDataHandler`. Embed `{ JobId = game.JobId, LockTime = os.time() }` in saved data; on load, refuse if `LockTime` < 600s old and `JobId ~= game.JobId`; release on save. [BUG-5]
- [x] Fix Bag-equip path: change `LoadoutManager.OnLoadoutRequest` slot whitelist to include `"Bag"` and add a `Type == "Bag"` enforcement branch parallel to Weapon/Kit. [BUG-1]
- [x] Fix `DayNightCycle.StartDay` off-by-one — start with `DayCount = 0` and only increment on transition, not on `Init`. [BUG-2]
- [x] Make Tower geometry distinct from Wall in `GameConfig.StructureProperties` (suggest Tower `Vector3.new(4, 16, 4)`, lighter color). [BUG-10]
- [x] Decide whether to keep `survival.project.json`. Either delete it or actually differentiate it (e.g., Survival project includes a different `_baseplate.rbxm` and excludes the lobby portal). [BUG-9] **Decision: deleted; revisit at Phase 2.1.**
- [x] Add `selene.toml` and `stylua.toml` and a CI step that runs both. [BUG-15]
- [x] Add a TestEZ-style harness under `tests/` and wire to CI **(scaffolding only — Studio runs work today; CI execution via run-in-roblox/Lune is a follow-up)**. [BUG-16]

**Artifacts:** PR per group. Suggested grouping: (cleanup), (datastore safety), (loadout fix), (tooling).

## Phase 1 — Make survival actually playable (combat + vitals)

**Goal:** The Survival place is winnable/losable. Players can take damage, deal damage, and starve.

**DoD:** A solo player can spawn into Survival, fight an enemy, get hit, get killed, run out of hunger, and die. Day → Night → Day cycle works, and a HUD shows the day count, time remaining, and vitals.

### 1.1 Combat

- [x] `src/server/CombatSystem.lua` (new). RemoteEvent `Attack`. Validates attacker has a weapon equipped, target is in range, applies damage based on `ItemDatabase[weapon].Damage`. Rate-limited per the existing pattern.
- [x] `src/client/CombatClient.client.lua` (new). On left-click or M1 press while a Weapon is equipped, fire `Attack` with the targeted enemy.
- [x] Update `WaveManager` enemies to deal damage on touch: connect `Touched` on the enemy's `HumanoidRootPart`, deal `damage = 5 + difficulty * 2` to the touched player's Humanoid, with a 1s per-player damage cooldown. [BUG-8]
- [x] On enemy death, award XP and a small Ruby drop (`PlayerDataHandler.AddCurrency(killer, "Rubies", 5 * difficulty)` + proportional split by damage contribution).
- [x] Despawn enemies at dawn: in `WaveManager.StartWave`, after the spawn loop ends, iterate currently-alive enemies and tween-out + destroy.

### 1.2 Vitals (hunger, thirst)

- [x] Add `Stats.Hunger`, `Stats.Thirst`, `Stats.MaxHunger=100`, `Stats.MaxThirst=100` to `DEFAULT_DATA` in `PlayerDataHandler`. Reconcile handles existing players.
- [x] `src/server/VitalsSystem.lua` (new). Tick every 5s; reduce Hunger by 1 and Thirst by 2; if either hits 0, deal 1 damage/sec to the player. Survival mode only.
- [x] `EatItem` RemoteEvent. Validates the item is `Type == "Food"` and the player owns it. Applies `+ItemDatabase[item].HungerRestore` and `RemoveItem(player, itemId, 1)`.
- [x] `DrinkItem` RemoteEvent. Same pattern with `Type == "Drink"`.
- [x] Add `cooked_fish` (Hunger 30, Type Food), `water_flask` (Thirst 50, Type Drink), `berries` (Hunger 8 + Thirst 5) to `ItemDatabase`. Promote `raw_fish` to `Type Food` with Hunger 10 and a `StomachAche` flag. [BUG-14]

### 1.3 HUD (the bare minimum)

- [x] `src/client/SurvivalHUD.client.lua` (new). Top-center: Day N + countdown using `PhaseChanged` payload. Bottom-left: three bars (Health from `Humanoid.Health`, Hunger and Thirst from `VitalsUpdate` events).
- [x] `VitalsUpdate` RemoteEvent: server fires `{Hunger, Thirst, MaxHunger, MaxThirst}` to the player on every change. _(landed in Phase 1.2)_
- [x] Hide `LoadoutUI` behind a toggle key (`Tab` / DPad-Down). [BUG-17]

### 1.4 Win/lose framing

- [x] `DayNightCycle` fires a `Day150Reached` RemoteEvent when `DayCount == 150` for the first time in a run. Client shows a celebratory banner that fades after 5s (run continues).
- [ ] After Day 150, flag the run as `EndlessMode = true` in match state and write the player's surviving-day count to a leaderboard DataStore on death or disconnect. _(Phase 5/7)_
- [ ] Difficulty curve in `WaveManager` keeps scaling past Day 150 with no cap. _(already true — difficulty = DayCount with no ceiling)_

## Phase 2 — World content (so the world isn't empty)

**Goal:** Resources respawn, structures persist, and a static starter map exists with a stronghold spawn pad and the Survival Portal.

**DoD:** A 4-player squad can join via the lobby portal, spawn into a real-looking Forest Kingdom map, gather all day, build a small base, and the base/inventory survives a server restart.

### 2.1 Map

- [x] `src/server/MapManager.lua` (new). On Survival start, looks for `ServerStorage.Maps.ForestKingdom` and clones it into `workspace.Map`. Counts gather-able nodes for a startup sanity check. Logs a warning and continues if the map is missing so the server still boots.
- [x] Rojo project files mount `assets/maps/` at `ServerStorage.Maps`. `assets/maps/README.md` documents how to author a `.rbxm` map in Studio.
- [ ] **(Studio task)** Author `assets/maps/ForestKingdom.rbxm` in Studio: stronghold pad in the centre, perimeter forest with named trees, scattered rock outcrops, ponds. Each gather-able node needs a `ProximityPrompt` named "Gather". See `assets/maps/README.md`.
- [ ] **(Studio task)** Add a `SurvivalPortal` model to the lobby map with a `ProximityPrompt` named `EnterSurvival`. Save under `assets/maps/Lobby.rbxm` (separate authoring task).

### 2.2 Resource respawn

- [x] `src/server/ResourceRespawn.lua` (new). When `ResourceManager` would destroy a node, snapshot it (Clone into `ServerStorage.ResourceRespawnPool`), destroy the world copy, and re-parent the snapshot back to its original parent at its original CFrame after `60..120` seconds. Snapshots include the full hierarchy (children, ProximityPrompts, attributes) so the respawned node is identical to the original. [BUG-6]
- [x] `src/server/ResourceManager.lua`: replace `resourceNode:Destroy()` with `ResourceRespawn.Schedule(resourceNode)` in the `DestroyOnGather` branch.

### 2.3 Structure persistence

- [x] `src/server/StructurePersistence.lua` (new). On `BuildingSystem.PlaceStructure` success, append a `{ structureType, cframeComponents, ownerUserId }` record to a per-Place DataStore (`Structures_v<GAME_VERSION>` keyed by `Place_<PlaceId>`). Saves are debounced (5s); final flush via `BindToClose`. On Survival server start, loads the saved list and re-instantiates each via the BuildingSystem renderer. [BUG-7]
- [ ] Add a destroy/damage system: `Structure.Health = props.Health`. Enemies attack walls if no players are in 30 studs. On 0 health, `Destroy()` the structure and remove from the persistence registry. _(deferred — Phase 5 raids)_
- [x] Add collision check in `BuildingSystem.PlaceStructure` using `OverlapParams` and `workspace:GetPartBoundsInBox`. Reject if any non-terrain part (excluding the placer's own character) is inside the proposed CFrame. [BUG-13]

### 2.4 Build placement preview (UX)

- [x] `src/client/BuildPlacementClient.client.lua` (new). Press `B` to enter build mode, `1`/`2` to switch between Wall/Tower, mouse positions a translucent ghost of the structure, click to send to server, `B`/`Esc` to exit. Ghost is green when valid, red when out of range or colliding (mirrors server checks). Survival-only — no-ops in Lobby.

## Phase 3 — Farming (the new pillar)

**Goal:** Players can plant, water, and harvest crops at the stronghold. Crops grow over real-time minutes and persist with the structure system.

**DoD:** A player can buy a `wheat_seed` from a vendor in the lobby, take it into Survival, plant it on a plot, water it, watch it grow visually, harvest `wheat`, and eat the wheat for hunger.

### 3.1 Schema

- [ ] `src/shared/CropDatabase.lua` (new). Each entry: `{ SeedItemId, CropItemId, GrowthStages = {...}, GrowthSeconds, WaterRequirement, Yield = {min, max}, PreferredBiomes = {...} }`.
- [ ] Add to `ItemDatabase`: `wheat_seed`, `wheat`, `carrot_seed`, `carrot`, `berry_seed`, `berries`. Add Type `Seed` and `Crop`. Crops have Hunger values.
- [ ] Add to `ItemDatabase`: `watering_can` (Tool), `hoe` (Tool), `fertilizer` (Material).

### 3.2 Plot system

- [ ] `src/server/PlotManager.lua` (new). Each plot is a `Part` with a `ProximityPrompt` named `Till` (when empty), `Plant` (when tilled), `Water` (when planted, dry), `Harvest` (when ready). Plot state lives in a per-match DataStore alongside structures.
- [ ] Plots are placed via the building system (`PlotKit` → `Type=Kit, StructureId=plot_01`).

### 3.3 Farming actions

- [ ] `src/server/FarmingSystem.lua` (new). RemoteEvents `PlantSeed(plot, seedItemId)`, `WaterCrop(plot)`, `HarvestCrop(plot)`. All rate-limited and distance-validated like `ResourceManager`.
- [ ] Growth tick: a single server-wide loop iterates all planted plots every 10s, advances stage if watered and time elapsed; otherwise increments dryness counter.
- [ ] Visual stages: swap the plot's child `Model` between 4 growth stages (sprout → leafy → flowering → ready).

### 3.4 UX

- [ ] `src/client/FarmingClient.client.lua` (new). Listen for `Plant`/`Water`/`Harvest` prompts. Show inventory-filtered seed selector when `Plant` is triggered.
- [ ] Add growth-time tooltip on hover: "Wheat — 8 minutes remaining."

## Phase 4 — The beast (vision pillar)

**Goal:** One main beast (Wendigo) prowls the Forest Kingdom map at night with the horror cues from the vision.

**DoD:** Playing solo at night, you hear footsteps and growls before you see anything. If you wander far from the stronghold, the beast may stalk you. A torch can briefly stun it.

### 4.1 Beast core

- [ ] `src/server/BeastSystem.lua` (new). Spawns one Beast per Survival run during night. Beast has stalking AI: stays at 50-100 studs from the nearest player, occasionally darts to 30 studs for a "glimpse," then retreats. If a player is 200+ studs from the stronghold for 60+ seconds, beast switches to Hunt state.
- [ ] Beast respects light: any source with `BeastRepel = true` attribute within 30 studs forces beast to retreat to >100 studs. Stronghold's main light has a larger radius.
- [ ] Beast Definitions module: `src/shared/BeastDatabase.lua` with `Wendigo`, `Yeti`, `DjinnStalker` placeholders (only Wendigo wired up at launch).

### 4.2 Audio cues

- [ ] `src/client/BeastAudioClient.client.lua` (new). On beast proximity (server fires a throttled `BeastNearby` RemoteEvent with distance bucket), play a layered sound: footsteps under 50 studs, breathing under 30, growl under 15. Use `SoundService` 3D sounds attached to invisible probe parts, not the beast itself, to keep the cues spooky-vague.
- [ ] Author/import 6 beast audio assets: ambient howl, footstep, branch snap, breathing, growl, chase music. Asset IDs in a new `src/shared/SoundConfig.lua`.

### 4.3 Jump-scare encounter

- [ ] When beast enters Hunt state on a specific player: server fires `BeastJumpScare` to that player. Client triggers camera shake (~0.6s), boosts ambient music, drops fog density temporarily. Beast moves to within 15 studs and lunges; player takes 30 damage if not behind cover.
- [ ] Portable light item: add `torch` (Tool with `BeastRepel = true`). Holding it active stuns the beast for 3s if it's within 20 studs.

## Phase 5 — Stronghold light, raids, residents

**Goal:** The stronghold feels like a place worth defending.

**DoD:** Every 5 nights a major raid attacks the stronghold, prioritizing the main light. Six residents wander the base, hide during raids, and provide passive bonuses.

### 5.1 Stronghold light

- [ ] Static `StrongholdLight` part in the map. Has `Health` and `BeastRepelRadius` attributes. Damage from raid enemies reduces both. At 0 health, the radius collapses and beasts can enter the base.
- [ ] `src/server/StrongholdLight.lua` (new). Tracks the light, broadcasts `LightChanged` to clients with new radius. Client renders an actual `PointLight` whose Range matches.

### 5.2 Raids

- [ ] `src/server/RaidManager.lua` (new). On `DayCount % 5 == 0` at night start, spawn a raid: `5 + DayCount` enemies, all targeting the StrongholdLight first then the nearest player.
- [ ] Special-event nights (Blood Moon, Eclipse, Beast Frenzy, Fog Night, Corrupted Storm): keyed by `DayCount` modulo + a deterministic RNG from the `MatchId` GUID. Each event modifies one parameter (more enemies, lower visibility, etc).

### 5.3 Residents

- [ ] `src/shared/ResidentDatabase.lua` (new). 12+ resident archetypes with rarity weights and bonus types (e.g., "+5% wood gather," "+10 max hunger").
- [ ] `src/server/ResidentManager.lua` (new). On Survival start, roll 6 residents from the pool using rarity weights. Spawn each as an NPC with a wander AI inside the stronghold. On raid start, each resident pathfinds to their assigned `ShelterPart` and stays put.
- [ ] Add a `residents` slot to player data (later persisted across runs as the lobby's stronghold roster).

## Phase 6 — Crafting, classes, and the second biome

**Goal:** The depth layer.

- [ ] `src/server/CraftingSystem.lua` and `src/shared/RecipeDatabase.lua`. Recipes like `wood_log×3 → wooden_axe`, `stone_ore×2 + wood_log → stone_pickaxe`, `iron_ore×1 + wood_log → iron_pickaxe`, `wheat×3 → bread`.
- [ ] Workbench structure: a `Kit` blueprint that places a Workbench `Model` with a `Craft` proximity prompt.
- [ ] `src/client/CraftingUI.client.lua` — recipe list filtered by inventory.
- [ ] Roles: introduce `Stats.RoleId` (default `Hunter`). Each role gives a passive bonus and a single active ability bound to `E`. Six launch roles per the vision.
- [ ] Author the Frozen Tundra map and wire Yeti as the second beast. Reuse the same systems with biome-specific resource tables and atmosphere.

## Phase 7 — Polish, audio everywhere, win flow

- [ ] `src/client/SoundController.client.lua` + asset IDs for chops, mines, hits, footsteps, ambience per biome.
- [ ] `src/client/VFXController.client.lua` — particles for chopping, fire, splashes, beast trail, raid impacts.
- [ ] Leaderboard for endless mode.
- [ ] Lobby vendor NPC + economy: turn `raw_fish` and `wood_log` into Rubies, spend Rubies on cosmetics and seed packs.
- [ ] Cosmetics & shop scaffolding (no real monetization yet).
- [ ] Tutorial: first-time-in-lobby ScreenGui that explains the loop in 30 seconds.

## Phase 8 — Third biome and beyond

- [ ] Desert Sultanate map + Djinn Stalker.
- [ ] Sub-beast pool (Shadow Hound, Nightcrawler, Mimic Beast, Hollow Watcher, Bone Stalker, Screaming Widow, Lantern Thief, Fog Wraith). One sub-beast rolled per run.
- [ ] Tier 2 stronghold upgrades (traps, forge, healing station, guard NPCs).
- [ ] Tier 3 stronghold upgrades (magic defenses, siege weapons, automation, portals).



---

# 4. Backlog & ideas

Things that don't fit a phase yet but we don't want to lose. Move into a phase when you commit to building.

- **Quests.** Daily/run-scoped quests like "gather 30 wood," "kill the sub-beast." Could share a system with achievements.
- **Hidden caves & dungeons.** Vision mentions these. Could be a phase 6+ thing — handcrafted mini-instances inside biome maps.
- **Mounts and pets.** Vision mentions these in the lobby. Pet pathfinding + inventory bonus.
- **Procedural map generation.** Long-term. Start with hand-built maps for the launch biomes.
- **Persistent world mode** + **guild strongholds** — server-cluster scale, way later.
- **Beast taming.** A Beast Tamer role unlocks taming a sub-beast as a temporary ally.
- **Stomach-ache debuff** when eating raw food. Cooking required for clean Hunger gain.
- **Cooking system.** `CookingSystem.lua` + `recipes_cooking` table. Campfires turn raw → cooked.
- **Storage chests.** Shared base storage with capacity and access controls.
- **Death and respawn loop.** Currently we use default Roblox respawn. Decide: lose all on death? lose a backpack? respawn at stronghold?
- **Voice chat / proximity voice.** Roblox supports it; could amplify horror.
- **Codes/promo system.** `CodesRedeemed` is already in the data schema; build the UI and admin tooling later.
- **Anti-AFK.** Players idling in the lobby/Survival should not block matchmaking slots.
- **Friends-only joins.** Vision says "reserved slots cannot be filled by strangers." Needs a party/lobby-key system on the matchmaking side.
- **Weather system.** Rain in Forest, snowstorms in Tundra, sandstorms in Desert. Affects visibility and beast cues.
- **Day-skip vote.** Let the squad vote to skip the rest of a Day Phase if they're ready.
- **Run tests in CI.** ✅ Done in cleanup pass — Lune-based unit tests run on every PR. Studio integration tests under `tests/unit/*.spec.lua` are still local-only; wiring them up via `@lune/roblox` instance shimming or [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox) is a future task.
- **Cleanup pass on the 24 Selene warnings.** ✅ Done in cleanup PR — all 24 warnings resolved; `--allow-warnings` removed from CI.
- **Adopt TestEZ proper.** Replace the in-repo `TestFramework.lua` shim with the real [TestEZ](https://roblox.github.io/testez/) once we install Wally.

---

# 5. Decision log

When we make a tradeoff that locks something in, record it here so future-us doesn't relitigate it.

| Date | Decision | Why | Status |
|---|---|---|---|
| 2026-05-28 | This document is the source of truth. Existing `optimization_notes.md` and `.Jules/*.md` stay as historical journals. | Single place to look for "what is the game and where are we." | Active |
| 2026-05-28 | **Squad size = 6.** Bumped `MAX_SESSION_PLAYERS` from 4 to 6 to match the vision. | Reserved-slot/invite-only joins are easier with headroom; matches design doc; trivial config change. | Done |
| 2026-05-28 | **Day 150 is a milestone, not a win.** The run does not end at Day 150. Players unlock endless leaderboard ranking and keep going. Difficulty continues scaling past 150 with no cap. | Maintains replayability and avoids a hard "you won, game over" off-ramp. Differentiates from the "Survive 99" pattern. | Done |
| 2026-05-28 | **Delete `survival.project.json`.** It was byte-identical to `default.project.json`. CI now builds once and publishes the same `.rbxl` to both Place IDs. We'll reintroduce a differentiated project at Phase 2.1 when there's actual place-specific content (e.g., a Forest Kingdom map shipped only to Survival). | YAGNI — solve the duplication when there's a real difference to encode. | Done (BUG-9) |

---

# How to keep this doc alive

This doc rots fast if we don't agree on rules. Keep it simple.

1. **Every PR that adds, removes, or meaningfully changes a system updates §2 (Current state) in the same PR.** No exceptions. Reviewers should reject if missing.
2. **Every new idea goes to §4 Backlog first.** Promote to a phase only when you commit to building it within the next few weeks.
3. **Every architectural tradeoff goes in §5 Decision log.** One row, one date, one sentence "why."
4. **Mark phase tasks with checkboxes.** Don't delete completed tasks for a few weeks — they show velocity. Archive them once the phase is fully done.
5. **`Last updated` at the top:** keep the date accurate.
6. **If the vision changes:** edit §1 first, then sweep §2 and §3 to make sure they still align. The vision drives everything.

When in doubt: prefer one extra paragraph in this file over a side document that nobody reads.

