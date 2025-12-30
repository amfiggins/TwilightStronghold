--[[
    LoadoutManager.lua
    Handles client requests to change their Loadout (Meta-Link).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

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
    if itemId and not GameConfig.Items[itemId] then
        warn("Invalid item ID")
        return
    end
    
    -- Execute
    -- Note: If itemId is nil, it means "Unequip"
    local success = PlayerDataHandler.SetLoadout(player, slot, itemId)
    
    if success then
        -- Feedback? (Optional)
    end
end

return LoadoutManager
