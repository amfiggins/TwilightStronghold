# Creating Your Roblox Places - Step by Step

> **Follow these instructions to create your Lobby and Survival Zone places**

---

## 📋 Understanding Roblox Structure

**Game/Experience** = The overall project (container)  
**Place** = A specific level/location within a game

**For this project:** We'll create **one game** with **two places** in it:
- **Lobby Place** - Where players farm and prepare
- **Survival Zone Place** - Where players fight waves

This is the simplest approach and makes management easier!

---

## 🎮 Step 1: Create Your Game and Lobby Place

### 1.1 Create the First Place (This Creates Your Game)
1. Open **Roblox Studio**
2. Click **"New"** button (top left)
3. Select **"Baseplate"** template
4. Click **"File"** → **"Publish to Roblox As..."**
5. In the dialog:
   - **Name**: `Twilight Stronghold` (this is your game name)
   - **Description**: `Build by Day. Survive by Night. Farm Forever.`
   - **Genre**: Choose "Adventure" or "RPG"
   - **Access**: Set to "Private" for now
6. Click **"Create"**

**✅ This creates your game AND your first place!**

### 1.2 Rename the First Place to "Lobby"
1. In Studio, look at the **Explorer** window (usually on the right)
2. At the very top, you'll see the place name (might be "Place" or "Baseplate")
3. Right-click on it → **"Rename"**
4. Name it: `Lobby`
5. Click **"File"** → **"Save to Roblox"** (or just save)

**📝 Note the Place ID** - Check the URL or go to roblox.com/develop → Places

---

## 🎮 Step 2: Add the Survival Zone Place to Your Game

### 1.1 Open Roblox Studio
1. Launch **Roblox Studio** (you should have it installed already)
2. Sign in with your Roblox account if prompted

### 1.2 Create a New Place
1. In Roblox Studio, click **"New"** button (top left, or File → New)
2. Select **"Baseplate"** template (or any template you prefer)
3. This creates a new place with a baseplate

### 1.3 Publish the Lobby Place
1. Click **"File"** in the menu bar
2. Select **"Publish to Roblox As..."**
3. In the dialog box:
   - **Name**: `Twilight Stronghold - Lobby`
   - **Description**: `The persistent hub where players farm resources and prepare for survival`
   - **Genre**: Choose "Adventure" or "RPG"
   - **Access**: Set to "Private" for now (you can change this later)
4. Click **"Create"** or **"Publish"**

### 1.4 Get the Lobby Place ID
After publishing, you'll see the place in your Roblox dashboard. To find the Place ID:

**Method 1: From Studio**
- After publishing, look at the URL in your browser (if it opened)
- The Place ID is the number in the URL: `https://www.roblox.com/games/PLACE_ID_HERE/...`

**Method 2: From Roblox Website**
1. Go to https://www.roblox.com/develop
2. Click on "Places" in the left sidebar
3. Find "Twilight Stronghold - Lobby"
4. Click on it
5. The Place ID is shown in the URL or in the place settings

**Method 3: From Studio (Alternative)**
- After publishing, go to **File → Game Settings**
- The Place ID might be shown there, or check the URL if Studio opened a browser window

**📝 Write down the Place ID** - you'll need it in a moment!

---

## 🎮 Step 2: Create the Survival Zone Place

### 2.1 Add a New Place to Your Existing Game
1. In Roblox Studio, click **"File"** → **"New"**
2. Select **"Baseplate"** template
3. Click **"File"** → **"Publish to Roblox As..."**
4. **IMPORTANT**: In the dialog, you'll see a dropdown for "Game"
   - Select your existing **"Twilight Stronghold"** game (the one you just created)
   - If you don't see it, make sure you're signed into the same Roblox account
5. In the dialog:
   - **Name**: `Survival Zone` (or `Survival`)
   - **Description**: `The survival zone where players fight waves of enemies`
   - **Access**: Set to "Private" for now
6. Click **"Create"**

**✅ This adds a second place to your existing game!**

### 2.2 Verify Both Places Exist
1. Go to https://www.roblox.com/develop
2. Click **"Places"** in the left sidebar
3. You should see your game "Twilight Stronghold" with two places:
   - Lobby
   - Survival Zone (or Survival)

### 2.3 Get Both Place IDs
1. Click on **"Lobby"** place
2. The Place ID is in the URL: `roblox.com/games/GAME_ID/PLACE_ID/...`
   - Or look in the place settings
3. Click on **"Survival Zone"** place
4. Note its Place ID too

**📝 Write down both Place IDs!**

---

## 🔧 Step 3: Update GameConfig.lua

Now that you have both Place IDs, let's update your code:

1. **Open Cursor** (your code editor)
2. **Open the file**: `src/shared/GameConfig.lua`
3. **Find this section** (around line 15-18):
   ```lua
   PLACE_IDS = {
       Lobby = 00000000, -- Replace with actual Lobby Place ID
       SurvivalZone = 11111111 -- Replace with actual Survival Place ID
   }
   ```

4. **Replace the placeholder numbers** with your actual Place IDs:
   ```lua
   PLACE_IDS = {
       Lobby = 123456789,        -- Your actual Lobby Place ID
       SurvivalZone = 987654321   -- Your actual Survival Place ID
   }
   ```

5. **Save the file** (Cmd+S or Ctrl+S)

---

## ✅ Verification Checklist

- [ ] Lobby place created and published
- [ ] Lobby Place ID written down
- [ ] Survival Zone place created and published
- [ ] Survival Zone Place ID written down
- [ ] `GameConfig.lua` updated with both Place IDs
- [ ] File saved

---

## 🎯 What's Next?

Once you've completed these steps:

1. **Test the setup** - We'll connect Rojo and test that everything works
2. **Enable DataStores** - Configure Studio to allow DataStore access
3. **Start Phase 1 Development** - Begin building the resource gathering system

---

## 💡 Tips

- **Keep both places private** for now - you can make them public later when ready
- **Place IDs are just numbers** - they look like: `1234567890`
- **You can always find Place IDs later** by going to your Roblox dashboard
- **Don't worry about the place content yet** - we'll build that as we develop

---

## 🐛 Troubleshooting

### "I can't find the Place ID"
- Check the URL after publishing - it's usually in the address bar
- Go to roblox.com/develop → Places → Click your place
- The Place ID is in the URL: `roblox.com/games/PLACE_ID/...`

### "I published but don't see it"
- Go to roblox.com/develop → Places
- It should appear in your list of places
- Make sure you're signed into the correct Roblox account

### "I want to change the place name later"
- That's fine! You can edit place names anytime
- The Place ID won't change, so your code will still work

---

**Ready?** Follow the steps above and let me know when you have both Place IDs! 🚀

