with open("src/client/SurvivalHUD.client.lua", "r") as f:
    content = f.read()

content = content.replace("if lastFillValues[fill] == clamped then return end", "if lastFillValues[fill] == clamped then\n        return\n    end")

with open("src/client/SurvivalHUD.client.lua", "w") as f:
    f.write(content)
