# Connecting Rojo to Roblox Studio - Step by Step

> **Follow these steps to sync your code from Cursor to Roblox Studio**

---

## ✅ Prerequisites Check

Before starting, make sure:
- [x] Rojo CLI is installed (`rojo --version` works)
- [x] Rojo extension is installed in Cursor
- [x] Your places are created
- [x] `default.project.json` exists in your project

---

## 🚀 Step 1: Start Rojo Server

**I've started the Rojo server for you!** It's running in the background.

**To verify it's running:**
- Check the terminal in Cursor - you should see: `Rojo is now listening on port 34872`
- If you don't see this, the server may have stopped

**To restart manually (if needed):**
1. Open terminal in Cursor
2. Run: `rojo serve`
3. Keep this terminal open (don't close it)

---

## 🔌 Step 2: Install Rojo Plugin in Studio

1. **Open Roblox Studio**
2. **Open the Toolbox:**
   - Click **"View"** in the menu bar
   - Click **"Toolbox"** (or press `Ctrl+9` / `Cmd+9`)
3. **Go to Plugins tab:**
   - In the Toolbox, click the **"Plugins"** tab (at the top)
4. **Search for Rojo:**
   - In the search box, type: `Rojo`
   - Look for the plugin by **"Rojo"** (official plugin)
5. **Install it:**
   - Click the **"Install"** button on the Rojo plugin
   - Wait for it to install (you'll see a checkmark when done)

**✅ Plugin installed!** You should see a Rojo button in your Studio toolbar.

---

## 🔗 Step 3: Connect Studio to Rojo

1. **In Roblox Studio**, look for the **Rojo plugin button** in the toolbar
   - It might be in the **"Plugins"** tab or in the main toolbar
   - Look for an icon that says "Rojo" or has a connection symbol

2. **Click the Rojo button**

3. **Click "Connect"** (or it might auto-connect)
   - The plugin should detect the running Rojo server
   - You should see a message like "Connected to Rojo"

4. **Verify connection:**
   - Check the **Explorer** window in Studio
   - You should see your code structure appear:
     - `Server` folder (with your server scripts)
     - `Client` folder (with your client scripts)
     - `Shared` folder (with GameConfig.lua)

**✅ If you see these folders, Rojo is connected!**

---

## 🧪 Step 4: Test Your Setup

### 4.1 Open Your Lobby Place
1. In Studio, click **"File"** → **"Open from Roblox"**
2. Select your **"Twilight Stronghold"** game
3. Select the **"Lobby"** place
4. Click **"Open"**

### 4.2 Test Server Scripts
1. Click the **"Test"** tab in Studio (or press `F5`)
2. Click **"Play"** button (or press `F5`)
3. Open the **Output** window:
   - Click **"View"** → **"Output"** (or press `Ctrl+Shift+O` / `Cmd+Shift+O`)
4. **Look for this message:**
   ```
   [Server] Starting Twilight Stronghold Server...
   [Server] All systems initialized.
   ```

**✅ If you see these messages, your code is running!**

### 4.3 Test Code Sync
1. **In Cursor**, open `src/shared/GameConfig.lua`
2. **Change something** (e.g., change `GAME_VERSION = "0.1.0-alpha"` to `GAME_VERSION = "0.1.0-test"`)
3. **Save the file** (`Cmd+S` or `Ctrl+S`)
4. **In Studio**, check if the change appears:
   - The change should sync automatically
   - You might need to refresh or wait a moment
   - Check the Explorer → Shared → GameConfig.lua

**✅ If changes sync, Rojo is working perfectly!**

---

## ⚙️ Step 5: Enable DataStores (Important!)

DataStores won't work in Studio unless you enable them:

1. In Studio, click **"Home"** tab
2. Click **"Game Settings"** button
3. Click the **"Security"** tab
4. **Enable**: ✅ **"Enable Studio Access to API Services"**
5. Click **"Save"**

**✅ This allows DataStores to work in Studio for testing!**

---

## 🐛 Troubleshooting

### "Rojo plugin not found"
- Make sure you're in the **Plugins** tab of the Toolbox
- Search for "Rojo" (not "Rojo LSP" or other variations)
- Try refreshing the Toolbox

### "Can't connect to Rojo"
- Make sure `rojo serve` is running in your terminal
- Check that the terminal shows: "Rojo is now listening on port 34872"
- Try restarting the Rojo server
- Make sure Studio and Cursor are on the same computer

### "Code doesn't appear in Studio"
- Make sure Rojo is connected (check the plugin status)
- Verify `default.project.json` exists in your project root
- Try disconnecting and reconnecting Rojo
- Check that your file paths in `default.project.json` are correct

### "Server scripts don't run"
- Make sure you're in the **Lobby** place (not Survival Zone)
- Check the Output window for error messages
- Verify scripts are in the correct folders (Server vs Client)
- Make sure file names end with `.server.lua` or `.client.lua`

### "DataStore errors"
- Enable "Studio Access to API Services" in Game Settings → Security
- Make sure you're signed into Roblox Studio
- Check that you have a valid Roblox account (not guest)

---

## ✅ Success Checklist

You're ready when:
- [x] Rojo server is running
- [x] Rojo plugin is installed in Studio
- [x] Studio is connected to Rojo
- [x] Code appears in Studio Explorer
- [x] Server scripts run without errors
- [x] DataStores are enabled
- [x] Code changes sync from Cursor to Studio

---

## 🎯 What's Next?

Once Rojo is connected and working:

1. **Start Phase 1 Development** - Begin building the resource gathering system
2. **Create your first resource node** - A simple tree with a ProximityPrompt
3. **Test the interaction** - Make sure gathering works

**You're almost ready to start building!** 🚀

---

## 💡 Tips

- **Keep Rojo server running** - Don't close the terminal while developing
- **Save frequently** - Changes sync automatically when you save
- **Check Output window** - It shows errors and debug messages
- **Test in Studio** - Always test your code in Studio before deploying

---

**Need help?** Check the Output window in Studio for specific error messages!

