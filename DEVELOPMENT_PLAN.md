# Twilight Stronghold - Development Plan

> **For First-Time Game Developers**  
> This plan breaks down the entire development process into manageable phases with clear goals and learning resources.

---

## 📚 Prerequisites & Setup

### What You Need
- **Roblox Studio** (free, download from roblox.com/create)
- **VS Code** (free code editor)
- **Rojo** (syncs VS Code to Roblox Studio)
- **Basic Lua knowledge** (we'll learn as we go!)

### Learning Resources
- **Roblox Developer Hub**: https://create.roblox.com/docs
- **Lua Basics**: https://www.lua.org/manual/5.4/
- **Rojo Setup**: https://rojo.space/docs/installation

---

## 🎯 Development Philosophy

**Build in Phases, Test Frequently, Iterate Quickly**

1. **Phase 0**: Setup & Foundation (Current)
2. **Phase 1**: Lobby MVP (Playable farming)
3. **Phase 2**: Survival MVP (Basic day/night cycle)
4. **Phase 3**: Core Loop (Connect lobby to survival)
5. **Phase 4**: Polish & Content
6. **Phase 5**: Advanced Features

**Goal**: Get to a playable MVP (Phase 3) as quickly as possible, then iterate.

---

## 📋 Phase 0: Foundation & Setup ✅ (Mostly Complete)

### Current Status
- ✅ Rojo project structure set up
- ✅ Basic code architecture in place
- ✅ Core systems scaffolded (PlayerDataHandler, LoadoutManager, etc.)

### What's Left
- [ ] **Set up Roblox Studio workspace**
  - Create two places: "Lobby" and "Survival Zone"
  - Configure Rojo to sync to Studio
  - Test that code changes appear in Studio
  
- [ ] **Set up DataStores**
  - Enable DataStore API in Roblox Studio
  - Test PlayerDataHandler save/load
  - Add error handling for DataStore failures

- [ ] **Create basic world structure**
  - Lobby: Simple terrain with a lake, trees, and mining area
  - Survival: Flat terrain for building (we'll add more later)

### Time Estimate: 2-4 hours

---

## 📋 Phase 1: Lobby MVP (Farming & Crafting)

**Goal**: Players can farm resources, craft items, and see their inventory.

### 1.1 Resource Gathering System

**What to Build:**
- Click/interact with resource nodes (trees, rocks, fishing spots)
- Minigame or simple click-to-gather
- Server validates and awards resources
- Resources appear in inventory

**Files to Modify:**
- `ResourceManager.lua` - Expand mock loot system
- `InteractionClient.client.lua` - Add visual feedback
- `MinigameController.lua` - Implement fishing/chopping minigames

**Tasks:**
- [ ] Create resource nodes in Roblox Studio (Parts with ProximityPrompts)
- [ ] Implement gathering cooldowns (prevent spam-clicking)
- [ ] Add visual feedback (particles, sounds, UI notifications)
- [ ] Create different resource types (wood, stone, fish, ore)
- [ ] Add tool requirements (need axe for trees, pickaxe for rocks)

**Learning Resources:**
- Roblox ProximityPrompts: https://create.roblox.com/docs/workspace/proximity-prompts
- Roblox Particles: https://create.roblox.com/docs/effects/particle-emitters

### 1.2 Inventory System

**What to Build:**
- UI showing player's inventory
- Display resources and items
- Stackable items (wood x50) vs unique items (sword)

**Files to Modify:**
- `PlayerDataHandler.lua` - Already has inventory structure
- Create new: `InventoryUI.client.lua`

**Tasks:**
- [ ] Design inventory UI (grid or list)
- [ ] Display items with icons/names
- [ ] Show quantities for stackable items
- [ ] Add sorting/filtering (optional for MVP)

**Learning Resources:**
- Roblox GUI Design: https://create.roblox.com/docs/ui
- Roblox UI Layouts: https://create.roblox.com/docs/ui/ui-layouts

### 1.3 Crafting System

**What to Build:**
- Crafting station/UI
- Recipe system (5 wood + 2 stone = sword)
- Craft items and add to inventory

**Files to Create:**
- `CraftingSystem.server.lua`
- `CraftingUI.client.lua`

**Tasks:**
- [ ] Define crafting recipes in GameConfig
- [ ] Create crafting UI
- [ ] Server validates player has materials
- [ ] Deduct materials and award crafted item
- [ ] Add crafting animations/feedback

**Example Recipe Structure:**
```lua
Recipes = {
    ["wooden_sword"] = {
        Materials = { {Item = "wood_log", Qty = 10}, {Item = "stone_ore", Qty = 5} },
        Result = {ItemId = "wooden_sword", Qty = 1}
    }
}
```

### 1.4 Currency & Trading (Optional for MVP)

**What to Build:**
- Sell resources for Rubies (lobby currency)
- Buy items from NPC shops

**Tasks:**
- [ ] Add "Sell" functionality to inventory
- [ ] Create shop NPCs with ProximityPrompts
- [ ] Implement buy/sell system

### Phase 1 Completion Criteria
- ✅ Players can gather 3+ resource types
- ✅ Inventory UI displays all items
- ✅ Players can craft at least 2 items
- ✅ Resources persist between sessions (DataStore)

**Time Estimate: 20-30 hours**

---

## 📋 Phase 2: Survival MVP (Day/Night Cycle)

**Goal**: Players can join survival, build defenses, and fight waves.

### 2.1 Matchmaking & Teleportation

**What to Build:**
- Queue system to join survival
- Teleport players to survival place
- Pass loadout data between places

**Files to Modify:**
- `MatchmakingService.lua` - Already scaffolded, needs completion

**Tasks:**
- [ ] Create "Join Queue" button in lobby
- [ ] Implement queue UI (shows players waiting)
- [ ] Test teleportation between places
- [ ] Pass loadout data via TeleportOptions
- [ ] Handle teleport failures gracefully

**Learning Resources:**
- Roblox TeleportService: https://create.roblox.com/docs/reference/engine/classes/TeleportService

### 2.2 Day/Night Cycle (Already Started!)

**What to Build:**
- Day phase: Build and gather
- Night phase: Combat
- Visual indicators (time remaining, phase name)

**Files to Modify:**
- `DayNightCycle.lua` - Already has basic loop
- Create: `DayNightUI.client.lua`

**Tasks:**
- [ ] Add UI showing current phase and time
- [ ] Adjust day/night lengths (balance gameplay)
- [ ] Add visual effects (lighting changes, skybox)
- [ ] Disable building during night phase
- [ ] Add countdown warnings (30 seconds until night)

### 2.3 Building System

**What to Build:**
- Place walls, towers, traps
- Use resources from inventory
- Validate placement (no clipping, within range)

**Files to Modify:**
- `BuildingSystem.lua` - Expand mock system
- Create: `BuildingUI.client.lua`

**Tasks:**
- [ ] Create building UI (select structure type)
- [ ] Implement placement preview (ghost structure)
- [ ] Server validates placement and resources
- [ ] Create structure models (walls, towers)
- [ ] Add building limits (max structures per player)
- [ ] Structures take damage during waves

**Learning Resources:**
- Roblox Raycasting: https://create.roblox.com/docs/workspace/raycasting
- Roblox Models: https://create.roblox.com/docs/studio/models

### 2.4 Enemy Waves

**What to Build:**
- Spawn enemies during night
- Enemies pathfind to player base
- Enemies attack structures and players
- Wave difficulty scales with day count

**Files to Modify:**
- `WaveManager.lua` - Expand mock spawning
- Create: `EnemyAI.server.lua`

**Tasks:**
- [ ] Create enemy models (start simple: basic NPC)
- [ ] Implement pathfinding (PathfindingService)
- [ ] Add enemy health and damage
- [ ] Create different enemy types (weak, fast, tanky)
- [ ] Scale enemy stats with wave number
- [ ] Add enemy death rewards (resources, currency)

**Learning Resources:**
- Roblox PathfindingService: https://create.roblox.com/docs/workspace/pathfinding
- Roblox Humanoid: https://create.roblox.com/docs/characters/humanoids

### 2.5 Combat System

**What to Build:**
- Players can attack enemies
- Weapons have damage values
- Health system for players
- Death = session end

**Files to Create:**
- `CombatSystem.server.lua`
- `CombatUI.client.lua`

**Tasks:**
- [ ] Implement weapon damage
- [ ] Add player health bar
- [ ] Create attack animations
- [ ] Handle player death (end session, save progress)
- [ ] Add respawn prevention during survival

### Phase 2 Completion Criteria
- ✅ Players can queue and join survival
- ✅ Day/night cycle works with UI
- ✅ Players can build 2+ structure types
- ✅ Enemies spawn and attack during night
- ✅ Players can fight enemies
- ✅ Death ends session and saves Diamonds

**Time Estimate: 30-40 hours**

---

## 📋 Phase 3: Core Loop (Connect Everything)

**Goal**: Complete the "split loop" - lobby farming feeds into survival.

### 3.1 Loadout System (Already Started!)

**What to Build:**
- Equip weapon and base kit from lobby
- Loadout appears in survival
- Visual representation of equipped items

**Files to Modify:**
- `LoadoutManager.lua` - Complete implementation
- `LoadoutUI.client.lua` - Show player's inventory

**Tasks:**
- [ ] Loadout UI shows owned items (not just mock buttons)
- [ ] Equipped weapon appears in survival
- [ ] Base kit spawns structures at match start
- [ ] Visual feedback when equipping items

### 3.2 Resource Transfer

**What to Build:**
- Resources gathered in survival stay in survival (session-only)
- Diamonds earned in survival persist to lobby
- Clear separation between lobby and survival resources

**Tasks:**
- [ ] Create session-only inventory for survival
- [ ] Award Diamonds on wave completion
- [ ] Save Diamonds to persistent data
- [ ] Use Diamonds in lobby for upgrades

### 3.3 Class/Profession System

**What to Build:**
- Choose class before survival (Warrior, Mage, Builder)
- Classes have unique abilities/stats
- Unlock classes with Diamonds

**Files to Create:**
- `ClassSystem.server.lua`
- `ClassSelectionUI.client.lua`

**Tasks:**
- [ ] Define class stats and abilities
- [ ] Create class selection UI
- [ ] Apply class bonuses in survival
- [ ] Add class-specific upgrades

### 3.4 Meta-Progression

**What to Build:**
- Permanent upgrades using Diamonds
- Upgrade classes, unlock new items
- Progression feels meaningful

**Tasks:**
- [ ] Create upgrade tree/UI
- [ ] Implement upgrade effects
- [ ] Balance upgrade costs
- [ ] Add visual progression indicators

### Phase 3 Completion Criteria
- ✅ Complete loadout system works end-to-end
- ✅ Resources properly separated (lobby vs survival)
- ✅ Diamonds earned and spent on upgrades
- ✅ Class system implemented
- ✅ Players can see meaningful progression

**Time Estimate: 20-30 hours**

---

## 📋 Phase 4: Polish & Content

**Goal**: Make the game feel complete and fun.

### 4.1 Visual Polish

**Tasks:**
- [ ] Improve UI design (consistent style, better colors)
- [ ] Add particle effects (gathering, combat, building)
- [ ] Improve lighting and atmosphere
- [ ] Add sound effects and music
- [ ] Create better models (replace placeholders)

### 4.2 Content Expansion

**Tasks:**
- [ ] Add more resource types (10+ types)
- [ ] Create more crafting recipes (20+ items)
- [ ] Add more enemy types (5+ varieties)
- [ ] Create more structure types (traps, gates, etc.)
- [ ] Add rare/legendary items with special effects

### 4.3 Balance & Tuning

**Tasks:**
- [ ] Playtest and adjust resource gathering rates
- [ ] Balance enemy difficulty scaling
- [ ] Tune crafting costs
- [ ] Adjust day/night cycle timing
- [ ] Balance currency economy

### 4.4 Quality of Life

**Tasks:**
- [ ] Add tooltips and help text
- [ ] Improve error messages
- [ ] Add settings menu (graphics, audio)
- [ ] Create tutorial/onboarding
- [ ] Add loading screens

**Time Estimate: 40-60 hours**

---

## 📋 Phase 5: Advanced Features

**Goal**: Add the "big ideas" from your roadmap.

### 5.1 Villager Rescue System

**Tasks:**
- [ ] Create villager NPCs in survival
- [ ] Implement rescue mechanics
- [ ] Add villager buffs/shops
- [ ] Create escort missions

### 5.2 Night Stalker Boss

**Tasks:**
- [ ] Design boss mechanics
- [ ] Implement adaptive AI
- [ ] Create capture/rescue system
- [ ] Add boss rewards

### 5.3 Guild System

**Tasks:**
- [ ] Create guild data structure
- [ ] Implement guild creation/joining
- [ ] Build shared guild hall
- [ ] Add guild progression

### 5.4 New Biomes

**Tasks:**
- [ ] Design ice lake biome
- [ ] Create volcanic forge area
- [ ] Add biome-specific resources
- [ ] Implement biome transitions

**Time Estimate: 60+ hours**

---

## 🛠️ Development Workflow

### Daily Routine
1. **Morning**: Review yesterday's work, plan today's tasks
2. **Development**: Work on one feature at a time
3. **Testing**: Test frequently in Roblox Studio
4. **Evening**: Commit changes, update progress

### Git Workflow (Using Feature Branches)
```bash
# Create feature branch
git checkout -b feat/resource-gathering

# Work and commit frequently
git add .
git commit -m "feat(resources): add tree gathering minigame"

# When feature complete, merge to dev
git checkout dev
git merge --squash feat/resource-gathering
git commit -m "feat(resources): complete resource gathering system"
```

### Testing Checklist (Before Moving to Next Phase)
- [ ] Feature works in isolation
- [ ] Feature integrates with existing systems
- [ ] No console errors
- [ ] Data persists correctly
- [ ] UI is functional (even if not pretty)
- [ ] Basic edge cases handled

---

## 🎓 Learning Path

### Week 1-2: Roblox Basics
- Learn Roblox Studio interface
- Understand Parts, Models, Instances
- Learn Lua basics (variables, functions, tables)
- Practice with simple scripts

### Week 3-4: Systems & Architecture
- Understand client/server architecture
- Learn RemoteEvents and RemoteFunctions
- Understand DataStores
- Practice with Rojo workflow

### Week 5-6: Game Development
- Learn pathfinding
- Understand Humanoids and animations
- Learn GUI creation
- Practice with ProximityPrompts

### Ongoing: Best Practices
- Code organization
- Error handling
- Performance optimization
- Security (anti-cheat basics)

---

## 🚨 Common Pitfalls & Solutions

### Problem: Code changes don't appear in Studio
**Solution**: Make sure Rojo is running and connected. Check `default.project.json` paths.

### Problem: DataStore errors
**Solution**: Enable DataStore API in Studio. Add retry logic for rate limits.

### Problem: Performance issues
**Solution**: Use object pooling for enemies. Limit particle effects. Optimize loops.

### Problem: Players can exploit/cheat
**Solution**: Always validate on server. Never trust client data. Use server-side cooldowns.

---

## 📊 Progress Tracking

### Phase Completion Checklist

**Phase 0: Foundation**
- [ ] Rojo setup working
- [ ] DataStores enabled
- [ ] Basic world created

**Phase 1: Lobby MVP**
- [ ] Resource gathering works
- [ ] Inventory displays
- [ ] Crafting functional

**Phase 2: Survival MVP**
- [ ] Matchmaking works
- [ ] Day/night cycle complete
- [ ] Building system works
- [ ] Enemy waves functional

**Phase 3: Core Loop**
- [ ] Loadout system complete
- [ ] Resource transfer works
- [ ] Class system implemented
- [ ] Meta-progression functional

---

## 🎯 Next Steps (Start Here!)

1. **Set up Roblox Studio workspace**
   - Create two places (Lobby and Survival)
   - Configure Rojo sync
   - Test that code appears in Studio

2. **Test existing systems**
   - Run the game in Studio
   - Check console for errors
   - Verify PlayerDataHandler loads data

3. **Start Phase 1: Resource Gathering**
   - Create a simple tree model in Studio
   - Add ProximityPrompt to tree
   - Test gathering interaction

4. **Build one feature at a time**
   - Don't try to do everything at once
   - Get one thing working, then move to the next
   - Test frequently

---

## 💡 Tips for Success

1. **Start Small**: Get one feature working perfectly before moving on
2. **Test Often**: Run the game after every change
3. **Use Placeholders**: Don't worry about graphics early - use simple parts
4. **Read Documentation**: Roblox docs are your friend
5. **Join Communities**: Roblox Developer Forums, Discord servers
6. **Be Patient**: Game development takes time, especially your first game
7. **Iterate**: Your first version won't be perfect - that's okay!

---

## 📞 Getting Help

- **Roblox Developer Forum**: https://devforum.roblox.com/
- **Roblox Discord**: Official Roblox Developer Discord
- **Stack Overflow**: Tag questions with `roblox` and `lua`
- **YouTube**: Many Roblox development tutorials available

---

**Remember**: The goal is to have fun and learn. Don't get discouraged if things don't work immediately. Every developer started where you are now!

Good luck with Twilight Stronghold! 🏰✨

