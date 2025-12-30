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
    
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Mock Inventory Buttons (Ideally this would read from a Client Data Cache)
createButton("Equip Void Sword", function()
    LoadoutEvent:FireServer("Weapon", "void_sword")
    print("Requested Void Sword")
end)

createButton("Unequip Weapon", function()
    LoadoutEvent:FireServer("Weapon", nil)
    print("Requested Unequip")
end)

createButton("Equip Watchtower", function()
    LoadoutEvent:FireServer("BaseKit", "watchtower_kit")
    print("Requested Watchtower")
end)
