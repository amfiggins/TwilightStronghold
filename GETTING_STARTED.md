# Getting Started - Your First Steps

> **Follow this checklist to get your project running**

---

## ✅ Immediate Action Checklist

### Step 1: Install Tools (30 minutes)
- [x] Install Roblox Studio
- [x] Install VS Code OR use Cursor (Cursor is VS Code-based and works perfectly)
- [x] Install Rojo CLI
- [x] Install Rojo extension in your code editor
- [x] Install Lua language server extension (optional)

**How to verify**: Open terminal, type `rojo --version` - should show version number

---

### Step 2: Create Roblox Places (15 minutes)
- [x] Create "Lobby" place in Roblox Studio
- [x] Publish Lobby place (note the Place ID)
- [x] Create "Survival Zone" place
- [x] Publish Survival Zone place (note the Place ID)
- [x] Update `src/shared/GameConfig.lua` with your Place IDs

**How to verify**: Place IDs should be numbers, not zeros

---

### Step 3: Connect Rojo (10 minutes)
- [x] Open terminal in project folder
- [x] Run `rojo serve`
- [x] Install Rojo plugin in Studio
- [x] Connect Studio to Rojo
- [x] Verify code appears in Studio Explorer

**How to verify**: You should see "Server", "Client", and "Shared" folders in Studio

---

### Step 4: Test Basic Setup (5 minutes)
- [x] Open Lobby place in Studio
- [x] Press Play (F5)
- [x] Check Output window
- [x] Should see: `[Server] Starting Twilight Stronghold Server...`

**If you see this message, your setup works!** 🎉

---

### Step 5: Enable DataStores (5 minutes)
- [ ] Open Output window (View → Output, or Ctrl+Shift+O / Cmd+Shift+O)
- [ ] In Studio, go to Game Settings
- [ ] Click "Security" tab
- [ ] Enable "Enable Studio Access to API Services"
- [ ] This allows DataStores to work in Studio

**How to verify**: Player data should save/load without errors

---

### Step 6: Create Your First Resource Node (15 minutes)
- [ ] In Studio, insert a Part (press M)
- [ ] Resize to look like a tree (tall and brown)
- [ ] Name it "Tree"
- [ ] Insert ProximityPrompt
- [ ] Parent ProximityPrompt to Tree
- [ ] Set ActionText to "Gather Wood"
- [ ] Press Play and test interaction

**How to verify**: Walk up to tree, press E, check Output for interaction message

---

## 🎯 What's Next?

Once you've completed the checklist above:

1. **Read the Development Plan**: Open `DEVELOPMENT_PLAN.md`
2. **Start Phase 1**: Begin with Resource Gathering system
3. **Build one feature at a time**: Don't try to do everything at once

---

## 🐛 Common Issues

### "Rojo won't connect"
- Make sure `rojo serve` is running in terminal
- Check that Rojo plugin is installed in Studio
- Try disconnecting and reconnecting

### "Code doesn't appear in Studio"
- Check `default.project.json` file exists
- Verify file paths are correct
- Restart Rojo server

### "DataStore errors"
- Enable "Studio Access to API Services" in Game Settings
- Make sure you're signed into Roblox Studio
- Check you have a Roblox account (not just guest)

### "Scripts don't run"
- Check Output window for error messages
- Verify scripts are in correct folders (Server vs Client)
- Make sure file names end with `.server.lua` or `.client.lua`

---

## 📚 Need Help?

- **Setup issues**: Check `QUICK_START.md` for detailed instructions
- **Development questions**: See `DEVELOPMENT_PLAN.md` for roadmap
- **Roblox help**: Visit https://create.roblox.com/docs
- **Community**: Join Roblox Developer Forum

---

## ✨ Success Criteria

You're ready to start developing when:

- ✅ Rojo connects and syncs code
- ✅ Server scripts run without errors
- ✅ You can create and interact with objects in Studio
- ✅ DataStores are enabled

**Once all checkboxes are done, you're ready to build!** 🚀

---

**Remember**: Take your time, test frequently, and don't be afraid to experiment. Every developer started where you are now!

Good luck! 🎮

