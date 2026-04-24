1:--[[
2:    PlayerDataHandler.lua
3:    Handles loading, saving, and managing player data using Roblox DataStores.
4:    Includes session locking and autosave functionality.
5:]]
6:
7:local Players = game:GetService("Players")
8:local DataStoreService = game:GetService("DataStoreService")
9:local HttpService = game:GetService("HttpService")
10:local RunService = game:GetService("RunService")
11:local ReplicatedStorage = game:GetService("ReplicatedStorage")
12:
13:local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
14:local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)
15:
16:local PlayerDataHandler = {}
17:local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_" .. GameConfig.GAME_VERSION)
18:
19:-- Default Data Schema
20:local DEFAULT_DATA = {
21:    Stats = {
22:        Rubies = 0, -- Lobby Currency (from selling fish/ores)
23:        Diamonds = 0, -- Premium/Survival Currency (from 99 Nights)
24:        Level = 1,
25:        XP = 0
26:    },
27:    Inventory = {
28:        -- Format: { Content = "wood", Qty = 10 }, { ItemId = "void_sword", GUID = "..." }
29:    },
30:    Loadout = {
31:        Weapon = nil, -- Usage: ItemId (e.g. "void_sword")
32:        BaseKit = nil
33:    },
34:    CodesRedeemed = {}
35:}
36:
37:-- Runtime session cache
38:local sessionData = {}
39:-- Runtime inventory lookup cache: [UserId] = { [ItemId] = slotIndex }
40:-- Optimization: Maps ItemId to the *first* index in inventory for O(1) checks.
41:local sessionInventoryLookup = {}
42:
43:-- Helper: Deep Copy Table
44:local function deepCopy(orig)
45:    local original_type = type(orig)
46:    local copy
47:    if original_type == 'table' then
48:        copy = {}
49:        for orig_key, orig_value in next, orig, nil do
50:            copy[deepCopy(orig_key)] = deepCopy(orig_value)
51:        end
52:        setmetatable(copy, deepCopy(getmetatable(orig)))
53:    else
54:        copy = orig
55:    end
56:    return copy
57:end
58:
59:-- Helper: Reconcile with default data (fills missing keys)
60:local function reconcile(target, template)
61:    for k, v in pairs(template) do
62:        if target[k] == nil then
63:            if type(v) == "table" then
64:                target[k] = deepCopy(v)
65:            else
66:                target[k] = v
67:            end
68:        elseif type(target[k]) == "table" and type(v) == "table" then
69:            reconcile(target[k], v)
70:        end
71:    end
72:end
73:
74:-- Helper: Rebuild Lookup for a user (O(N)) - Called when indices shift
75:local function rebuildLookup(userId)
76:    local data = sessionData[userId]
77:    if not data then return end
78:
79:    local lookup = {}
80:    for i, slot in ipairs(data.Inventory) do
81:        -- Only store the first occurrence to preserve "first found" logic
82:        if not lookup[slot.ItemId] then
83:            lookup[slot.ItemId] = i
84:        end
85:    end
86:    sessionInventoryLookup[userId] = lookup
87:end
88:
89:-- Helper: Retry GetAsync with Exponential Backoff
90:local function retryGetAsync(store, key, retries, baseDelay)
91:    retries = retries or 3
92:    baseDelay = baseDelay or 1
93:
94:    local currentTry = 0
95:    local success, result
96:
97:    while currentTry <= retries do
98:        success, result = pcall(function()
99:            return store:GetAsync(key)
100:        end)
101:
102:        if success then
103:            return true, result
104:        else
105:            currentTry = currentTry + 1
106:            if currentTry <= retries then
107:                warn(string.format("[Data] GetAsync failed for key %s (Attempt %d/%d): %s. Retrying...", key, currentTry, retries + 1, tostring(result)))
108:                task.wait(baseDelay * (2 ^ (currentTry - 1)))
109:            end
110:        end
111:    end
112:
113:    return false, result
114:end
115:
116:function PlayerDataHandler.Init()
117:    -- Setup Remotes
118:    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
119:    if not Remotes then
120:        Remotes = Instance.new("Folder")
121:        Remotes.Name = "Remotes"
122:        Remotes.Parent = ReplicatedStorage
123:    end
124:
125:    local GetPlayerData = Instance.new("RemoteFunction")
126:    GetPlayerData.Name = "GetPlayerData"
127:    GetPlayerData.Parent = Remotes
128:
129:    GetPlayerData.OnServerInvoke = function(player)
130:        local start = os.clock()
131:        local data = PlayerDataHandler.Get(player)
132:        -- Poll until data exists or timeout (5 seconds)
133:        while not data and (os.clock() - start) < 5 do
134:            task.wait(0.1)
135:            data = PlayerDataHandler.Get(player)
136:        end
137:        return data
138:    end
139:
140:    Players.PlayerAdded:Connect(PlayerDataHandler.OnPlayerAdded)
141:    Players.PlayerRemoving:Connect(PlayerDataHandler.OnPlayerRemoving)
142:
143:    -- Autosave Loop
144:    task.spawn(function()
145:        local playerIndex = 1
146:        while true do
147:            local players = Players:GetPlayers()
148:            local playerCount = #players
149:
150:            if playerCount > 0 then
151:                -- Stagger saves over 60 seconds to prevent DataStore throttling
152:                local interval = 60 / playerCount
153:
154:                -- Wrap index if it exceeds current player count
155:                if playerIndex > playerCount then
156:                    playerIndex = 1
157:                end
158:
159:                local player = players[playerIndex]
160:                if player then
161:                    task.spawn(function()
162:                        PlayerDataHandler.Save(player)
163:                    end)
164:                end
165:
166:                playerIndex = playerIndex + 1
167:                task.wait(interval)
168:            else
169:                playerIndex = 1
170:                task.wait(5)
171:            end
172:        end
173:    end)
174:end
175:
176:function PlayerDataHandler.OnPlayerAdded(player)
177:    local userId = player.UserId
178:    local key = "Player_" .. userId
179:
180:    local success, data = retryGetAsync(PlayerDataStore, key, 3, 2)
181:
182:    if success then
183:        data = data or deepCopy(DEFAULT_DATA)
184:        reconcile(data, DEFAULT_DATA)
185:        sessionData[userId] = data
186:
187:        -- Build Lookup Table
188:        rebuildLookup(userId)
189:
190:        -- Setup Leaderstats (Visual Debug)
191:        local ls = Instance.new("Folder")
192:        ls.Name = "leaderstats"
193:        ls.Parent = player
194:
195:        local rubies = Instance.new("IntValue")
196:        rubies.Name = "Rubies"
197:        rubies.Value = data.Stats.Rubies
198:        rubies.Parent = ls
199:
200:        local diamonds = Instance.new("IntValue")
201:        diamonds.Name = "Diamonds"
202:        diamonds.Value = data.Stats.Diamonds
203:        diamonds.Parent = ls
204:
205:        print(string.format("[Data] Loaded data for %s", player.Name))
206:    else
207:        warn(string.format("[Data] Failed to load data for %s: %s", player.Name, tostring(data)))
208:        -- Kick to prevent data loss or overwriting with empty data
209:        player:Kick("Failed to load data. Please rejoin.")
210:    end
211:end
212:
213:function PlayerDataHandler.OnPlayerRemoving(player)
214:    PlayerDataHandler.Save(player)
215:    sessionData[player.UserId] = nil
216:    sessionInventoryLookup[player.UserId] = nil
217:end
218:
219:function PlayerDataHandler.Save(player)
220:    local userId = player.UserId
221:    local data = sessionData[userId]
222:
223:    if not data then return end
224:
225:    local key = "Player_" .. userId
226:
227:    local success, err = pcall(function()
228:        PlayerDataStore:UpdateAsync(key, function(oldData)
229:            -- UpdateAsync is safer than SetAsync as it prevents data corruption
230:            -- from concurrent writes and respects session locks.
231:            return data
232:        end)
233:    end)
234:
235:    if success then
236:        print(string.format("[Data] Saved data for %s", player.Name))
237:    else
238:        warn(string.format("[Data] Failed to save data for %s: %s", player.Name, tostring(err)))
239:    end
240:end
241:
242:-- Public API to get data
243:function PlayerDataHandler.Get(player)
244:    return sessionData[player.UserId]
245:end
246:
247:-- Public API to Add Item
248:function PlayerDataHandler.AddItem(player, itemId, quantity)
249:    local userId = player.UserId
250:    local data = sessionData[userId]
251:    if not data then return false, "NoData" end
252:
253:    -- Ensure lookup exists (safety)
254:    if not sessionInventoryLookup[userId] then
255:        rebuildLookup(userId)
256:    end
257:    local lookup = sessionInventoryLookup[userId]
258:    quantity = quantity or 1
259:    if type(quantity) ~= "number" or quantity <= 0 then
260:        return false, "InvalidQuantity"
261:    end
262:
263:    local itemDef = ItemDatabase.GetItem(itemId)
264:    local isStackable = true
265:    if itemDef and itemDef.Stackable == false then
266:        isStackable = false
267:    end
268:
269:    if isStackable then
270:        -- Check if item exists (Stacking logic for "Materials")
271:        -- Optimization: Use GetItem (which uses Lookup O(1))
272:        local slot = PlayerDataHandler.GetItem(player, itemId)
273:
274:        if slot then
275:            slot.Qty = (slot.Qty or 1) + quantity
276:        else
277:            -- Not found, Add new slot
278:            if #data.Inventory >= GameConfig.INVENTORY_CAPACITY then
279:                return false, "InventoryFull"
280:            end
281:            table.insert(data.Inventory, { ItemId = itemId, Qty = quantity })
282:            -- Update Lookup
283:            lookup[itemId] = #data.Inventory
284:        end
285:    else
286:        -- Non-stackable logic: Items with unique GUIDs
287:        if #data.Inventory + quantity <= GameConfig.INVENTORY_CAPACITY then
288:            for _ = 1, quantity do
289:                table.insert(data.Inventory, {
290:                    ItemId = itemId,
291:                    Qty = 1,
292:                    GUID = HttpService:GenerateGUID(false)
293:                })
294:                -- Update Lookup (point to first one if not set)
295:                if not lookup[itemId] then
296:                    lookup[itemId] = #data.Inventory
297:                end
298:            end
299:        else
300:            return false, "InventoryFull"
301:        end
302:    end
303:
304:    return true, "Success"
305:end
306:
307:-- Public API to Add Currency
308:function PlayerDataHandler.AddCurrency(player, currencyType, amount)
309:    local data = sessionData[player.UserId]
310:    if not data then return false end
311:
312:    if type(amount) ~= "number" or amount <= 0 then
313:        return false
314:    end
315:
316:    if data.Stats[currencyType] then
317:        data.Stats[currencyType] = data.Stats[currencyType] + amount
318:
319:        -- Update Leaderstats
320:        local ls = player:FindFirstChild("leaderstats")
321:        if ls and ls:FindFirstChild(currencyType) then
322:            ls[currencyType].Value = data.Stats[currencyType]
323:        end
324:        return true
325:    end
326:    return false
327:end
328:
329:-- Public API to Get Item
330:function PlayerDataHandler.GetItem(player, itemId)
331:    local userId = player.UserId
332:    local data = sessionData[userId]
333:    if not data then return nil end
334:
335:    -- Optimization: Use Lookup Table (O(1))
336:    local lookup = sessionInventoryLookup[userId]
337:    if lookup and lookup[itemId] then
338:        return data.Inventory[lookup[itemId]]
339:    end
340:
341:    return nil
342:end
343:
344:-- Public API to Remove Item
345:function PlayerDataHandler.RemoveItem(player, itemId, quantity)
346:    local userId = player.UserId
347:    local data = sessionData[userId]
348:    if not data then return false end
349:
350:    quantity = quantity or 1
351:    if type(quantity) ~= "number" or quantity <= 0 then
352:        return false
353:    end
354:
355:    -- Optimization: Use Lookup Table to find slot (O(1))
356:    local lookup = sessionInventoryLookup[userId]
357:    local slotIndex = lookup and lookup[itemId]
358:
359:    if not slotIndex then return false end -- Not found
360:
361:    local slot = data.Inventory[slotIndex]
362:    if not slot or slot.ItemId ~= itemId then
363:        -- Desync or invalid lookup
364:        return false
365:    end
366:    local currentQty = slot.Qty or 1
367:
368:
369:
370:    if currentQty < quantity then
371:        return false -- Not enough items
372:    end
373:
374:    -- Deduct
375:    local newQty = currentQty - quantity
376:    if newQty <= 0 then
377:        -- Remove slot
378:        table.remove(data.Inventory, slotIndex)
379:        -- Indices shifted, we must rebuild lookup (O(N))
380:        rebuildLookup(userId)
381:    else
382:        -- Update slot
383:        slot.Qty = newQty
384:        -- Lookup index remains valid
385:    end
386:
387:    return true
388:end
389:
390:-- Public API to Set Loadout
391:function PlayerDataHandler.SetLoadout(player, slot, itemId)
392:    local data = sessionData[player.UserId]
393:    if not data then return false end
394:
395:    -- Slot must be "Weapon" or "BaseKit" based on our schema
396:    if slot ~= "Weapon" and slot ~= "BaseKit" then return false end
397:
398:    -- Verification: Does player own this item?
399:    if itemId and not PlayerDataHandler.GetItem(player, itemId) then
400:        return false
401:    end
402:
403:    data.Loadout[slot] = itemId
404:    return true
405:end
406:
407:return PlayerDataHandler
