--[[
    LoadoutManager.lua
    Handles client requests to change their Loadout (Meta-Link).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

local LoadoutManager = {}

-- Create Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LoadoutEvent = Instance.new("RemoteEvent", Remotes)
LoadoutEvent.Name = "SetLoadout"

function LoadoutManager.Init()
    LoadoutEvent.OnServerEvent:Connect(LoadoutManager.OnLoadoutRequest)
    print("[LoadoutManager] Initialized. Listening for Loadout events.")
end

function LoadoutManager.OnLoadoutRequest(player, slot, itemId)
    print(string.format("[LoadoutManager] Request from %s: Set %s to %s", player.Name, tostring(slot), tostring(itemId)))
    
    -- Validation 1: Slot must be valid
    if slot ~= "Weapon" and slot ~= "BaseKit" then 
        warn("Invalid slot") 
        return 
    end
    
    -- Validation 2: Item ID must exist in GameConfig
    -- Sentinel: Type checking is critical here. Clients can send any type (e.g. bool, table).
    -- If itemId is not nil, it must be a string and exist in the database.
    if itemId ~= nil then
        if type(itemId) ~= "string" then
            warn(string.format("[LoadoutManager] Security: Invalid itemId type (%s) from %s", type(itemId), player.Name))
            return
        end

        local itemDef = ItemDatabase.GetItem(itemId)
        if not itemDef then
            warn(string.format("[LoadoutManager] Invalid item ID: %s", itemId))
            return
        end

        -- Sentinel: Enforce Type Constraints (e.g., prevent equipping Logs as Weapons)
        if slot == "Weapon" and itemDef.Type ~= "Weapon" then
            warn(string.format("[LoadoutManager] Security: Type Mismatch (Weapon) for %s by %s", itemId, player.Name))
            return
        elseif slot == "BaseKit" and itemDef.Type ~= "Kit" then
            warn(string.format("[LoadoutManager] Security: Type Mismatch (Kit) for %s by %s", itemId, player.Name))
            return
        end
    end
    
    -- Execute
    -- Note: If itemId is nil, it means "Unequip"
    local success = PlayerDataHandler.SetLoadout(player, slot, itemId)
    
    if success then
        -- Feedback? (Optional)
    end
end

return LoadoutManager
