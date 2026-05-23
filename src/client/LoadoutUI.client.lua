--[[
    LoadoutUI.client.lua
    Basic UI to select Loadout items (Weapon/BaseKit).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local ItemDatabase = require(ReplicatedStorage.Shared.ItemDatabase)

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
title.BorderSizePixel = 0
title.Parent = frame

-- Refresh Container (Micro-UX)
local refreshContainer = Instance.new("Frame")
refreshContainer.Size = UDim2.new(0, 30, 1, 0)
refreshContainer.Position = UDim2.new(1, -30, 0, 0)
refreshContainer.BackgroundTransparency = 1
refreshContainer.Parent = title

-- Refresh Button (Micro-UX)
local refreshBtn = Instance.new("TextButton")
refreshBtn.Text = "↻"
refreshBtn.Size = UDim2.new(1, 0, 1, 0)
refreshBtn.AnchorPoint = Vector2.new(0.5, 0.5)
refreshBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
refreshBtn.BackgroundTransparency = 1
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 18
refreshBtn.Parent = refreshContainer

-- Refresh Tooltip (Micro-UX)
local refreshTooltip = Instance.new("TextLabel")
refreshTooltip.Text = "Refresh Inventory"
refreshTooltip.Size = UDim2.new(0, 120, 0, 24)
refreshTooltip.AnchorPoint = Vector2.new(1, 0)
refreshTooltip.Position = UDim2.new(1, 0, -1, -5) -- Above the button
refreshTooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
refreshTooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshTooltip.BorderSizePixel = 0
refreshTooltip.Font = Enum.Font.SourceSans
refreshTooltip.TextSize = 12
refreshTooltip.Visible = false
refreshTooltip.ZIndex = 10
refreshTooltip.Parent = refreshContainer

local function updateRefreshState(isActive)
    refreshBtn.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    refreshTooltip.Visible = isActive
end

refreshBtn.MouseEnter:Connect(function() updateRefreshState(true) end)
refreshBtn.MouseLeave:Connect(function() updateRefreshState(false) end)
refreshBtn.SelectionGained:Connect(function() updateRefreshState(true) end)
refreshBtn.SelectionLost:Connect(function() updateRefreshState(false) end)

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
    toast.Parent = frame -- Keep toast on frame, over the list

    local info = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(toast, info, { TextTransparency = 1, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.8, 0) })
    tween:Play()
    tween.Completed:Connect(function() toast:Destroy() end)
end

-- Helper: Create Button
local function createButton(text, onClick, rarityColor, isEquipped, rarityName, subtext)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    -- Visual State: Green if equipped, Dark Gray if not
    btn.BackgroundColor3 = isEquipped and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = isEquipped and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 255, 255)

    -- RichText Configuration
    btn.RichText = true
    btn.TextXAlignment = Enum.TextXAlignment.Left

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = btn

    local displayText = isEquipped and "✓ " .. text or text
    if subtext then
        btn.Text = "<b>" .. displayText .. "</b>\n<font size='12' color='#BBBBBB'>" .. subtext .. "</font>"
    else
        btn.Text = displayText
    end

    btn.Font = isEquipped and Enum.Font.GothamBold or Enum.Font.SourceSans
    btn.Parent = listContainer -- Parent to ScrollingFrame
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0

    -- Micro-UX: Rarity Indicator
    local rarityLabel
    if rarityColor then
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 4, 1, 0)
        bar.BackgroundColor3 = rarityColor
        bar.BorderSizePixel = 0
        bar.Parent = btn

        if rarityName then
            rarityLabel = Instance.new("TextLabel")
            rarityLabel.Text = rarityName
            rarityLabel.Size = UDim2.new(0, 100, 1, 0)
            rarityLabel.Position = UDim2.new(1, -10, 0, 0)
            rarityLabel.AnchorPoint = Vector2.new(1, 0)
            rarityLabel.BackgroundTransparency = 1
            rarityLabel.TextColor3 = rarityColor
            rarityLabel.Font = Enum.Font.GothamBold
            rarityLabel.TextSize = 12
            rarityLabel.TextXAlignment = Enum.TextXAlignment.Right
            rarityLabel.Visible = false
            rarityLabel.Parent = btn
        end
    end

    local function updateState(isHovered)
        -- Always show rarity on hover for scanability
        if rarityLabel then rarityLabel.Visible = isHovered end

        if isEquipped then
            -- Interactive feedback even for equipped items (Brighter Green)
            btn.BackgroundColor3 = isHovered and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(30, 80, 30)
        else
            btn.BackgroundColor3 = isHovered and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60)
        end
    end

    btn.MouseEnter:Connect(function() updateState(true) end)
    btn.MouseLeave:Connect(function() updateState(false) end)
    btn.SelectionGained:Connect(function() updateState(true) end)
    btn.SelectionLost:Connect(function() updateState(false) end)
    
    btn.MouseButton1Click:Connect(function()
        if isEquipped then
            showToast("Already equipped")
            return
        end

        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        onClick()
    end)
    return btn
end

local isRefreshing = false
local refreshAnimConnection = nil

-- Populate Inventory Buttons
local function populateLoadout()
    if isRefreshing then return end
    isRefreshing = true

    refreshAnimConnection = RunService.RenderStepped:Connect(function(dt)
        refreshBtn.Rotation = (refreshBtn.Rotation + dt * 360) % 360
    end)

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

    if loadingLabel then loadingLabel:Destroy() end

    if not success then
        warn("Failed to fetch player data:", data)
        showToast("Failed to load data")
        local errorLabel = Instance.new("TextLabel")
        errorLabel.Text = "Connection Error"
        errorLabel.Size = UDim2.new(1, 0, 0, 40)
        errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        errorLabel.BackgroundTransparency = 1
        errorLabel.Font = Enum.Font.SourceSansBold
        errorLabel.TextSize = 14
        errorLabel.Parent = listContainer

        refreshBtn.Rotation = 0
        if refreshAnimConnection then
            refreshAnimConnection:Disconnect()
            refreshAnimConnection = nil
        end
        isRefreshing = false
        return
    end

    local inventory = (data and data.Inventory) or {}
    local currentLoadout = (data and data.Loadout) or {}

    -- Dynamic Unequip Options
    if currentLoadout.Weapon then
        local itemDef = ItemDatabase.GetItem(currentLoadout.Weapon)
        local name = itemDef and itemDef.Name or "Weapon"
        createButton("Unequip " .. name, function()
            LoadoutEvent:FireServer("Weapon", nil)
            showToast("Unequipped " .. name)
            task.delay(0.5, populateLoadout)
        end, nil, false, nil, "Click to unequip weapon")
    end

    if currentLoadout.BaseKit then
        local itemDef = ItemDatabase.GetItem(currentLoadout.BaseKit)
        local name = itemDef and itemDef.Name or "Kit"
        createButton("Unequip " .. name, function()
            LoadoutEvent:FireServer("BaseKit", nil)
            showToast("Unequipped " .. name)
            task.delay(0.5, populateLoadout)
        end, nil, false, nil, "Click to unequip kit")
    end

    local foundItems = 0

    -- Dynamic Items
    for _, item in ipairs(inventory) do
        local itemDef = ItemDatabase.GetItem(item.ItemId)
        if itemDef then
            local slot = nil
            local subtext = itemDef.Description or ""

            if itemDef.Type == "Weapon" then
                slot = "Weapon"
                if itemDef.Damage then
                    subtext = "Damage: " .. tostring(itemDef.Damage)
                end
            elseif itemDef.Type == "Kit" then
                slot = "BaseKit"
                if itemDef.StructureId then
                    subtext = "Structure: " .. tostring(itemDef.StructureId)
                end
            elseif itemDef.Type == "Bag" then
                slot = "Bag"
                if itemDef.Capacity then
                    subtext = "Capacity: " .. tostring(itemDef.Capacity) .. " slots"
                end
            end

            if slot then
                foundItems = foundItems + 1
                -- Resolve Rarity Color
                local rarityColor = nil
                local rarityName = nil
                if itemDef.Rarity and GameConfig.Rarity[itemDef.Rarity] then
                    rarityColor = GameConfig.Rarity[itemDef.Rarity].Color
                    rarityName = GameConfig.Rarity[itemDef.Rarity].Name
                end

                -- Check if equipped
                local isEquipped = (currentLoadout[slot] == item.ItemId)

                -- Cleaner text for equipped items (Status vs Action)
                local btnText = isEquipped and itemDef.Name or "Equip " .. itemDef.Name

                createButton(btnText, function()
                    LoadoutEvent:FireServer(slot, item.ItemId)
                    showToast("Equipped " .. itemDef.Name)
                    -- Don't auto-refresh immediately to keep UI stable, user can click Refresh if needed
                    -- or we can wait a bit
                    task.delay(0.5, populateLoadout)
                end, rarityColor, isEquipped, rarityName, subtext)
            end
        end
    end

    -- Empty State
    if foundItems == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "No loadout items found.\nGather resources to craft weapons!"
        emptyLabel.Size = UDim2.new(1, 0, 0, 60)
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 16
        emptyLabel.Parent = listContainer
    end

    refreshBtn.Rotation = 0
    if refreshAnimConnection then
        refreshAnimConnection:Disconnect()
        refreshAnimConnection = nil
    end
    isRefreshing = false
end

-- Refresh Logic
refreshBtn.MouseButton1Click:Connect(function()
    -- Click Animation (Non-blocking)
    task.spawn(function()
        refreshBtn.TextSize = 14
        task.wait(0.1)
        refreshBtn.TextSize = 18
    end)

    populateLoadout()
end)

-- Run population
task.spawn(populateLoadout)
