import sys

with open("src/client/FarmingClient.client.lua", "r") as f:
    content = f.read()

search = """RunService.RenderStepped:Connect(function()
    local target = mouse.Target
    if not target or target.Name ~= "Plot" then
        tooltipLabel.Visible = false
        return
    end"""

replace = """-- ⚡ Bolt: Caching previous state to prevent high-frequency TweenService allocations and string updates
local lastTooltipText = ""
local lastTarget = nil
local lastVisible = nil

RunService.RenderStepped:Connect(function()
    local target = mouse.Target
    if not target or target.Name ~= "Plot" then
        if lastVisible ~= false then
            lastVisible = false
            tooltipLabel.Visible = false
        end
        return
    end"""

search2 = """    local text
    if state == "tilled" then
        text = "<b>Empty plot</b>\\n<font size='11' color='#BBBBBB'>Press the prompt to plant a seed</font>"
    elseif state == "ready" then
        text = string.format("<b>%s</b>\\n<font size='11' color='#FFD66A'>Ready to harvest</font>", cropName or "Crop")
    elseif state == "growing" then
        local now = workspace:GetServerTimeNow()
        local finishTime = target:GetAttribute("GrowFinishTime") or now
        text = string.format("<b>%s</b>\\n<font size='11' color='#BBBBBB'>%s</font>", cropName or "Crop", formatTimeRemaining(finishTime - now))
    else
        text = "<b>Plot</b>\\n<font size='11' color='#BBBBBB'>Use Hoe to till</font>"
    end

    tooltipLabel.Text = text
    tooltipLabel.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 16)
    tooltipLabel.Visible = true"""

replace2 = """    local text
    if state == "tilled" then
        text = "<b>Empty plot</b>\\n<font size='11' color='#BBBBBB'>Press the prompt to plant a seed</font>"
    elseif state == "ready" then
        text = string.format("<b>%s</b>\\n<font size='11' color='#FFD66A'>Ready to harvest</font>", cropName or "Crop")
    elseif state == "growing" then
        local now = workspace:GetServerTimeNow()
        local finishTime = target:GetAttribute("GrowFinishTime") or now
        text = string.format("<b>%s</b>\\n<font size='11' color='#BBBBBB'>%s</font>", cropName or "Crop", formatTimeRemaining(finishTime - now))
    else
        text = "<b>Plot</b>\\n<font size='11' color='#BBBBBB'>Use Hoe to till</font>"
    end

    if text ~= lastTooltipText then
        lastTooltipText = text
        tooltipLabel.Text = text
    end
    tooltipLabel.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 16)
    if lastVisible ~= true then
        lastVisible = true
        tooltipLabel.Visible = true
    end"""

if search in content and search2 in content:
    content = content.replace(search, replace, 1)
    content = content.replace(search2, replace2, 1)
    with open("src/client/FarmingClient.client.lua", "w") as f:
        f.write(content)
    print("Patched FarmingClient.client.lua")
else:
    print("Could not find search blocks in FarmingClient.client.lua")
