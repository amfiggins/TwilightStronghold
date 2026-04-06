with open('src/client/MinigameController.lua', 'r') as f:
    content = f.read()

old_touch = """UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    activeTouches = math.max(0, activeTouches - 1)
end)"""

new_touch = """UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    activeTouches = math.max(0, activeTouches - 1)
end)

UserInputService.TouchCanceled:Connect(function(touch, gameProcessed)
    activeTouches = math.max(0, activeTouches - 1)
end)"""

content = content.replace(old_touch, new_touch)

with open('src/client/MinigameController.lua', 'w') as f:
    f.write(content)
