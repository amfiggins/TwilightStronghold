--[[
    LoadoutUI.client.lua
    Basic UI to select Loadout items (Weapon/BaseKit).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
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
frame.Size = UDim2.new(0, 220, 0, 350) -- Adjusted width for scrollbar
frame.Position = UDim2.new(0.05, 0, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "Loadout (Meta-Link)"
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- Refresh Button (Micro-UX)
local refreshBtn = Instance.new("TextButton")
refreshBtn.Text = "↻"
refreshBtn.Size = UDim2.new(0, 30, 1, 0)
refreshBtn.Position = UDim2.new(1, -30, 0, 0)
refreshBtn.BackgroundTransparency = 1
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 18
refreshBtn.Parent = title

refreshBtn.MouseEnter:Connect(function() refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end)
refreshBtn.MouseLeave:Connect(function() refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200) end)

-- List Container (ScrollingFrame for Scanability)
local listContainer = Instance.new("ScrollingFrame")
listContainer.Size = UDim2.new(1, 0, 1, -30)
listContainer.Position = UDim2.new(0, 0, 0, 30)
listContainer.BackgroundTransparency = 1
listContainer.BorderSizePixel = 0
listContainer.ScrollBarThickness = 6
listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
listContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
listContainer.Parent = frame

-- List Layout
local layout = Instance.new("UIListLayout")
layout.Parent = listContainer -- Parent to ScrollingFrame
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10) -- Adjusted padding since title is separate
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = listContainer

-- Helper: Toast Notification
local function showToast(text)
    local toast = Instance.new("TextLabel")
    toast.Text = text
    toast.Size = UDim2.new(0, 180, 0, 30)
    toast.AnchorPoint = Vector2.new(0.5, 0.5)
    toast.Position = UDim2.new(0.5, 0, 0.9, 0) -- Bottom of frame
    toast.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toast.TextColor3 = Color3.fromRGB(255, 255, 255)
    toast.Font = Enum.Font.GothamBold
    toast.TextSize = 14
    toast.BorderSizePixel = 0
    toast.ZIndex = 10
    toast.Parent = frame

    local info = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(toast, info, { TextTransparency = 1, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.8, 0) })
    tween:Play()
    tween.Completed:Connect(function() toast:Destroy() end)
end

-- Helper: Create Button
local function createButton(text, onClick, rarityColor, isEquipped)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    -- Visual State: Green if equipped, Dark Gray if not
    btn.BackgroundColor3 = isEquipped and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = isEquipped and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 255, 255)
    btn.Text = isEquipped and "✓ " .. text or text
    btn.Font = isEquipped and Enum.Font.GothamBold or Enum.Font.SourceSans
    btn.Parent = listContainer -- Parent to ScrollingFrame
    btn.AutoButtonColor = false

    -- Micro-UX: Rarity Indicator
    if rarityColor then
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 4, 1, 0)
        bar.BackgroundColor3 = rarityColor
        bar.BorderSizePixel = 0
        bar.Parent = btn
    end

    btn.MouseEnter:Connect(function()
        if not isEquipped then
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    btn.MouseLeave:Connect(function()
        if not isEquipped then
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        if isEquipped then return end

        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        onClick()
    end)
    return btn
end

local isLoading = false

-- Populate Inventory Buttons
local function populateLoadout()
    if isLoading then return end
    isLoading = true
    refreshBtn.Text = "..."

    -- Clear List (preserve layout)
    for _, child in ipairs(listContainer:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    -- Loading Indicator
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Text = "Loading inventory..."
    loadingLabel.Size = UDim2.new(1, 0, 0, 30)
    loadingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Font = Enum.Font.SourceSansItalic
    loadingLabel.TextSize = 18
    loadingLabel.Parent = listContainer -- Parent to ScrollingFrame

    -- Fetch Data
    local success, data = pcall(function()
        return GetPlayerData:InvokeServer()
    end)

    if not success then
        warn("Failed to fetch player data:", data)
        if loadingLabel then loadingLabel:Destroy() end
        local errLabel = Instance.new("TextLabel")
        errLabel.Text = "Failed to load inventory."
        errLabel.Size = UDim2.new(1, 0, 0, 30)
        errLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        errLabel.BackgroundTransparency = 1
        errLabel.Parent = listContainer
        isLoading = false
        refreshBtn.Text = "↻"
        return
    end

    if loadingLabel then loadingLabel:Destroy() end

    if not success or not data then
        local errLabel = Instance.new("TextLabel")
        errLabel.Text = "Failed to load inventory."
        errLabel.Size = UDim2.new(1, 0, 0, 30)
        errLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        errLabel.BackgroundTransparency = 1
        errLabel.Parent = listContainer
        return
    end

    local inventory = data.Inventory or {}
    local currentLoadout = data.Loadout or {}

    -- Static Unequip Options
    createButton("Unequip Weapon", function()
        LoadoutEvent:FireServer("Weapon", nil)
        showToast("Unequipped Weapon")
    end)

    createButton("Unequip Kit", function()
        LoadoutEvent:FireServer("BaseKit", nil)
        showToast("Unequipped Kit")
    end)

    local foundItems = false

    -- Dynamic Items
    if #inventory == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "No items found."
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.SourceSansItalic
        emptyLabel.TextSize = 16
        emptyLabel.Parent = frame
    end

    for _, item in ipairs(inventory) do
        local itemDef = GameConfig.Items[item.ItemId]
        if itemDef then
            local slot = nil
            if itemDef.Type == "Weapon" then
                slot = "Weapon"
            elseif itemDef.Type == "Kit" then
                slot = "BaseKit"
            end

            if slot then
                foundItems = true
                -- Resolve Rarity Color
                local rarityColor = nil
                if itemDef.Rarity and GameConfig.Rarity[itemDef.Rarity] then
                    rarityColor = GameConfig.Rarity[itemDef.Rarity].Color
                end

                -- Check if equipped
                local isEquipped = (currentLoadout[slot] == item.ItemId)

                createButton("Equip " .. itemDef.Name, function()
                    LoadoutEvent:FireServer(slot, item.ItemId)
                    showToast("Equipped " .. itemDef.Name)
                end, rarityColor, isEquipped)
            end
        end
    end

    -- Empty State
    if not foundItems then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "No loadout items found.\nGather resources to craft weapons!"
        emptyLabel.Size = UDim2.new(1, 0, 0, 60)
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 16
        emptyLabel.Parent = listContainer
    end

    isLoading = false
    refreshBtn.Text = "↻"
end

-- Refresh Logic
refreshBtn.MouseButton1Click:Connect(function()
    populateLoadout()
end)

-- Run population
task.spawn(populateLoadout)
