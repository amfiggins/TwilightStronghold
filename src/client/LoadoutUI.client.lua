--[[
    LoadoutUI.client.lua
    Basic UI to select Loadout items (Weapon/BaseKit).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LoadoutEvent = Remotes:WaitForChild("SetLoadout")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")

local gui = Instance.new("ScreenGui")
gui.Name = "LoadoutUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Container
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.05, 0, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "Loadout (Meta-Link)"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- List Layout
local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 35)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = frame

-- Helper: Create Button
local function createButton(text, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Parent = frame
    btn.AutoButtonColor = false

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)

    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        onClick()
    end)
    return btn
end

-- Populate Inventory Buttons
local function populateLoadout()
    -- Loading Indicator
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Text = "Loading inventory..."
    loadingLabel.Size = UDim2.new(1, 0, 0, 30)
    loadingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Font = Enum.Font.SourceSansItalic
    loadingLabel.TextSize = 18
    loadingLabel.Parent = frame

    -- Fetch Data
    local data = GetPlayerData:InvokeServer()
    if loadingLabel then loadingLabel:Destroy() end
    local inventory = data and data.Inventory or {}

    -- Clear existing buttons if any (though this runs once currently)
    -- If we wanted to refresh, we'd need to clear children of 'frame' except title, layout, padding.
    -- For now, this just adds to the initial frame setup.

    -- Static Unequip Options
    createButton("Unequip Weapon", function()
        LoadoutEvent:FireServer("Weapon", nil)
        print("Requested Unequip Weapon")
    end)

    createButton("Unequip Kit", function()
        LoadoutEvent:FireServer("BaseKit", nil)
        print("Requested Unequip Kit")
    end)

    -- Dynamic Items
    for _, item in ipairs(inventory) do
        local itemDef = GameConfig.Items[item.ItemId]
        if itemDef then
            local slot = nil
            if itemDef.Type == "Weapon" then
                slot = "Weapon"
            elseif itemDef.Type == "Kit" then
                slot = "BaseKit"
            elseif itemDef.Type == "Bag" then
                slot = "Bag"
            end

            if slot then
                createButton("Equip " .. itemDef.Name, function()
                    LoadoutEvent:FireServer(slot, item.ItemId)
                    print("Requested " .. itemDef.Name)
                end)
            end
        end
    end
end

-- Run population
task.spawn(populateLoadout)
