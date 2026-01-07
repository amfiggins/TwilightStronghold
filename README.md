# Twilight Stronghold

> "Build by Day. Survive by Night. Farm Forever."

A hybrid survival RPG for Roblox that combines persistent collection gameplay with high-stakes roguelite survival.

## 🎮 Game Overview

**The Twilight Stronghold** features two interconnected phases:

- **The Lobby**: A persistent hub where players farm resources, craft items, and prepare for survival
- **The War Zone**: A session-based survival mode where players build defenses and fight waves of enemies

See [GameOverview.md](./GameOverview.md) for the complete game design document.

## 🚀 Quick Start

**New to game development?** Start here:

1. Read [QUICK_START.md](./QUICK_START.md) - Get your development environment set up
2. Read [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) - Understand the development roadmap
3. Start with Phase 1: Resource Gathering

## 📁 Project Structure

```
TwilightStronghold/
├── src/
│   ├── client/          # Client-side scripts (UI, interactions)
│   ├── server/          # Server-side scripts (game logic, data)
│   └── shared/          # Shared code (config, constants)
├── default.project.json # Rojo configuration
├── GameOverview.md      # Game design document
├── DEVELOPMENT_PLAN.md  # Complete development roadmap
└── QUICK_START.md       # Setup guide
```

## 🛠️ Technology Stack

- **Roblox Studio**: Game engine and editor
- **Lua**: Programming language
- **Code Editor**: VS Code or Cursor (VS Code-based, works with Rojo)
- **Rojo**: Code editor to Studio synchronization
- **DataStores**: Player data persistence

## 📋 Current Status

### ✅ Completed
- Project structure and architecture
- Basic systems scaffolded:
  - PlayerDataHandler (save/load data)
  - LoadoutManager (equip items)
  - DayNightCycle (survival loop)
  - WaveManager (enemy spawning)
  - ResourceManager (gathering)
  - MatchmakingService (queue system)

### 🚧 In Progress
- Phase 0: Foundation setup
- Testing existing systems

### 📝 Next Up
- Phase 1: Lobby MVP (Resource Gathering, Inventory, Crafting)

## 🎯 Development Phases

1. **Phase 0**: Foundation & Setup ← You are here
2. **Phase 1**: Lobby MVP (Farming & Crafting)
3. **Phase 2**: Survival MVP (Day/Night & Combat)
4. **Phase 3**: Core Loop (Connect Everything)
5. **Phase 4**: Polish & Content
6. **Phase 5**: Advanced Features

See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for detailed breakdown.

## 📚 Learning Resources

- [Roblox Developer Hub](https://create.roblox.com/docs)
- [Lua Manual](https://www.lua.org/manual/5.4/)
- [Rojo Documentation](https://rojo.space/docs)
- [Roblox Developer Forum](https://devforum.roblox.com/)

## 🤝 Contributing

This is a solo project, but if you're learning alongside:
- Follow the development plan phases
- Test thoroughly before moving to next phase
- Document any issues you encounter
- Keep code organized and commented

## 📝 Notes

- This project uses **Rojo** for professional development workflow
- All game logic is in Lua scripts
- Data persistence uses Roblox DataStores
- Code follows Roblox best practices (client/server separation)

## 🎓 For First-Time Developers

**Don't worry if this seems overwhelming!** Game development is a journey:

1. **Start small**: Get one feature working at a time
2. **Test often**: Run the game after every change
3. **Read errors**: The Output window is your friend
4. **Be patient**: Your first game takes time
5. **Have fun**: Learning should be enjoyable!

The development plan breaks everything into manageable chunks. Follow it step by step, and you'll build a complete game.

---

**Ready to start?** → [QUICK_START.md](./QUICK_START.md)

