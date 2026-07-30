import re

with open('src/client/FarmingClient.client.lua', 'r') as f:
    content = f.read()

# 1. Update close button
old_close = """    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Text = "✕"
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(closeSelector)"""

new_close = """    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Text = "✕"
    closeBtn.Parent = frame

    local function updateCloseState(isHovered)
        closeBtn.TextColor3 = isHovered and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    end
    closeBtn.MouseEnter:Connect(function()
        updateCloseState(true)
    end)
    closeBtn.MouseLeave:Connect(function()
        updateCloseState(false)
    end)
    closeBtn.SelectionGained:Connect(function()
        updateCloseState(true)
    end)
    closeBtn.SelectionLost:Connect(function()
        updateCloseState(false)
    end)

    closeBtn.MouseButton1Click:Connect(closeSelector)"""

content = content.replace(old_close, new_close, 1)


# 2. Update list buttons
old_btn = """            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(80, 100, 80)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)
            btn.MouseButton1Click:Connect(function()"""

new_btn = """            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local function updateBtnState(isHovered)
                btn.BackgroundColor3 = isHovered and Color3.fromRGB(80, 100, 80) or Color3.fromRGB(60, 60, 60)
            end
            btn.MouseEnter:Connect(function()
                updateBtnState(true)
            end)
            btn.MouseLeave:Connect(function()
                updateBtnState(false)
            end)
            btn.SelectionGained:Connect(function()
                updateBtnState(true)
            end)
            btn.SelectionLost:Connect(function()
                updateBtnState(false)
            end)

            btn.MouseButton1Click:Connect(function()"""

content = content.replace(old_btn, new_btn, 1)

with open('src/client/FarmingClient.client.lua', 'w') as f:
    f.write(content)
