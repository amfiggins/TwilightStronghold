--[[
    CombatClient.client.lua
    Sends server-validated Attack requests when the player clicks (M1) or
    presses the gamepad right trigger while a Weapon is equipped.

    The server is the source of truth — we only send the *target candidate*
    (a Model) and let the server validate ownership, range, cooldown, and
    that the target is a registered enemy.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
-- Combat is Survival-only. In Lobby mode the Attack remote never appears,
-- so wait briefly and bail out instead of blocking forever.
local AttackEvent = Remotes:WaitForChild("Attack", 10)
if not AttackEvent then
    print("[CombatClient] No Attack remote (Lobby mode). Idle.")
    return
end

-- Walk up from the part the user is aiming at to find a Model with a
-- Humanoid. The server still verifies the model is a registered enemy,
-- so a malicious client gains nothing by sending arbitrary models.
local function pickTarget()
    local targetPart = mouse.Target
    if not targetPart then
        return nil
    end
    local model = targetPart:FindFirstAncestorOfClass("Model")
    if not model or model == player.Character then
        return nil
    end
    if not model:FindFirstChildOfClass("Humanoid") then
        return nil
    end
    return model
end

local function tryAttack()
    local target = pickTarget()
    if target then
        AttackEvent:FireServer(target)
    end
end

-- Mouse click + gamepad right trigger. Touch input intentionally omitted —
-- a mobile attack button will arrive with the HUD in Phase 1.3.
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then
        return -- UI absorbed the click
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        tryAttack()
        -- selene: allow(if_same_then_else)
    elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
        tryAttack()
    end
end)

print("[CombatClient] Initialized.")
