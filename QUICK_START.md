# Quick Start Guide - Twilight Stronghold

> **Get up and running in 30 minutes!**

---

## 🚀 Step 1: Install Required Tools (15 minutes)

### 1.1 Install Roblox Studio
1. Go to https://www.roblox.com/create
2. Click "Start Creating"
3. Download and install Roblox Studio
4. Sign in with your Roblox account

### 1.2 Install Code Editor (VS Code or Cursor)
**Option A: VS Code**
1. Go to https://code.visualstudio.com/
2. Download and install VS Code

**Option B: Cursor (Recommended if you already have it)**
- Cursor is VS Code-based and works perfectly with Rojo
- If you already have Cursor installed, you can skip VS Code
- All VS Code extensions work in Cursor

### 1.3 Install Rojo
1. Open your code editor (VS Code or Cursor)
2. Install the "Rojo" extension (search "Rojo" in Extensions)
3. Install Rojo CLI:
   - **Windows**: `iwr -useb https://rojo.space/install.ps1 | iex`
   - **Mac/Linux**: `curl -fsSL https://rojo.space/install.sh | sh`
4. Verify installation: Open terminal and type `rojo --version`

### 1.4 Install Lua Language Server (Optional but Recommended)
1. In your code editor, install "Lua" extension by sumneko
2. This gives you code completion and error checking

---

## 🎮 Step 2: Set Up Your First Place (10 minutes)

### 2.1 Create Lobby Place
1. Open Roblox Studio
2. Click "New" → "Baseplate" (or start from template)
3. Click "File" → "Publish to Roblox As..."
4. Name it "Twilight Stronghold - Lobby"
5. Note the Place ID (shown in URL or place settings)

### 2.2 Create Survival Place
1. Create another new place
2. Publish as "Twilight Stronghold - Survival"
3. Note the Place ID

### 2.3 Update GameConfig
1. Open `src/shared/GameConfig.lua` in your code editor
2. Replace the placeholder Place IDs:
   ```lua
   PLACE_IDS = {
       Lobby = YOUR_LOBBY_PLACE_ID,
       SurvivalZone = YOUR_SURVIVAL_PLACE_ID
   }
   ```

---

## 🔧 Step 3: Connect Rojo to Studio (5 minutes)

### 3.1 Start Rojo Server
1. Open terminal in your project folder
2. Run: `rojo serve`
3. You should see: "Rojo is now listening on port 34872"

### 3.2 Connect Studio to Rojo
1. In Roblox Studio, install "Rojo" plugin:
   - View → Toolbox → Plugins
   - Search "Rojo" and install
2. Click the Rojo plugin button in Studio
3. Click "Connect" (should connect automatically)
4. You should see your code structure appear in Explorer!

---

## ✅ Step 4: Test Your Setup (5 minutes)

### 4.1 Test Code Sync
1. In your code editor, open `src/shared/GameConfig.lua`
2. Change `GAME_VERSION = "0.1.0-alpha"` to `GAME_VERSION = "0.1.0-test"`
3. Save the file
4. In Studio, check if the change appears (may need to refresh)

### 4.2 Test Server Script
1. In Studio, go to "Test" tab
2. Click "Play" (or press F5)
3. Open "Output" window (View → Output)
4. You should see: `[Server] Starting Twilight Stronghold Server...`
5. If you see this, **congratulations!** Your setup works! 🎉

---

## 🐛 Troubleshooting

### Rojo won't connect
- Make sure `rojo serve` is running
- Check that port 34872 isn't blocked by firewall
- Try restarting Studio

### Code doesn't appear in Studio
- Make sure Rojo plugin is installed and connected
- Check `default.project.json` paths are correct
- Try disconnecting and reconnecting Rojo

### Server scripts don't run
- Check Output window for errors
- Make sure scripts are in ServerScriptService
- Verify file names end with `.server.lua` or `.client.lua`

### DataStore errors
- Go to Game Settings → Security
- Enable "Enable Studio Access to API Services"
- This allows DataStores to work in Studio

---

## 📚 Next Steps

Once your setup is working:

1. **Read the Development Plan**: `DEVELOPMENT_PLAN.md`
2. **Start Phase 1**: Resource Gathering
3. **Create your first resource node**: A simple Part with a ProximityPrompt

---

## 🎯 Your First Feature: Simple Resource Gathering

### Create a Tree in Studio
1. Insert → Part (or press M)
2. Resize it to look like a tree trunk
3. Change color to brown
4. Name it "Tree"

### Add Interaction
1. Insert → ProximityPrompt
2. Parent it to the Tree
3. Set ActionText to "Gather Wood"
4. Set ObjectText to "Tree"

### Test It
1. Press Play in Studio
2. Walk up to the tree
3. Press E (or click the prompt)
4. Check Output for: `[InteractionClient] Starting Minigame...`

**If you see this message, you've successfully created your first interactive element!** 🎉

---

## 💡 Tips

- **Save frequently** in both your code editor and Studio
- **Test often** - run the game after every change
- **Read errors** - the Output window tells you what's wrong
- **Start simple** - get basic features working before adding complexity

---

**You're ready to start developing!** Check out `DEVELOPMENT_PLAN.md` for your roadmap.

Good luck! 🚀

