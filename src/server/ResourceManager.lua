--[[
    ResourceManager.lua
    Handles server-side validation of resource gathering and awards items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ResourceManager = {}

-- Create Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder", ReplicatedStorage)
RemotesFolder.Name = "Remotes"

local GatherEvent = Instance.new("RemoteEvent", RemotesFolder)
GatherEvent.Name = "GatherResource"

function ResourceManager.Init()
    GatherEvent.OnServerEvent:Connect(ResourceManager.OnGatherRequest)
    print("[ResourceManager] Initialized. Listening for Gather events.")
end

function ResourceManager.OnGatherRequest(player, resourceId)
    -- 1. Validation Logic
    -- In a real game, we'd check distance between player and resourceId, cooldowns, and tool equipped.
    -- For this MVP Prototype, we trust the client's "Success" for now but log it.
    
    -- Determine what they got (Simulating logic)
    -- In reality, resourceId would map to a specific node type
    local drop = GameConfig.Resources["Tree"] -- Defaulting to Tree for test
    
    -- Logic: Roll for Rarity (The "Fisch" mechanic)
    local roll = math.random(1, 100)
    local itemAwarded = "wood_log"
    local qty = 1
    
    if roll > 95 then
        itemAwarded = "golden_wood" -- Rare drop!
    end
    
    -- Verify Inventory Cap? (Skip for now)
    
    -- Add Item
    local success = PlayerDataHandler.AddItem(player, itemAwarded, qty)
    
    if success then
        print(string.format("[ResourceManager] Awarded %s x%d to %s", itemAwarded, qty, player.Name))
        -- Notify client of successful gathering
        GatherEvent:FireClient(player, itemAwarded, qty)
    end
end

return ResourceManager
