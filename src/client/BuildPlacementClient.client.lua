--[[
    BuildPlacementClient.client.lua
    Survival-only. Toggles a "build mode" where a translucent ghost of the
    selected structure follows the cursor. Click to place, B to exit.

    Controls:
        B           toggle build mode on/off
        1           select Wall
        2           select Tower
        Mouse       move ghost
        M1 click    place (fires PlaceStructure to the server)
        Esc / B     exit build mode

    The ghost is purely cosmetic — the server is still authoritative on
    range, collision, and cost. We do range and collision checks on the
    client only to colour the ghost red when placement would be rejected,
    so players don't fire useless click → reject round-trips.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Bail out in Lobby — the PlaceStructure remote only exists in Survival.
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceStructureEvent = Remotes:WaitForChild("PlaceStructure", 10)
if not PlaceStructureEvent then
    print("[BuildPlacementClient] No PlaceStructure remote (Lobby mode). Idle.")
    return
end

-- ── Config ────────────────────────────────────────────────────────────────
-- Default ordering for the 1/2 keys. When we add more structure types
-- (Phase 5+), this will become a longer list and the UI hint string
-- below will be regenerated.
local STRUCTURE_ORDER = { "Wall", "Tower" }

-- Visual feedback colours for the ghost (kept distinct from the real
-- structure colour so it's always clear the player is in build mode).
local COLOR_VALID = Color3.fromRGB(80, 255, 120)
local COLOR_INVALID = Color3.fromRGB(255, 80, 80)
local GHOST_TRANSPARENCY = 0.55

-- ── State ─────────────────────────────────────────────────────────────────
local active = false
local selected = STRUCTURE_ORDER[1]
local ghost = nil :: Part?
local hint = nil :: ScreenGui?
local renderConn = nil :: RBXScriptConnection?
local clickConn = nil :: RBXScriptConnection?

-- Reusable raycast/overlap params so we don't allocate per-frame.
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

-- ── UI hint ───────────────────────────────────────────────────────────────
local function buildHintGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "BuildHint"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(360, 30)
    frame.Position = UDim2.new(0.5, -180, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "HintLabel"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.RichText = true
    label.Parent = frame

    return gui, label
end

local hintLabel = nil :: TextLabel?

local function updateHint()
    if not hintLabel then
        return
    end
    -- Build the "1: Wall  2: Tower" portion dynamically.
    local parts = {}
    for index, name in ipairs(STRUCTURE_ORDER) do
        local prefix = (selected == name) and "<b>" or ""
        local suffix = (selected == name) and "</b>" or ""
        table.insert(parts, string.format("%s%d: %s%s", prefix, index, name, suffix))
    end
    hintLabel.Text = string.format("%s   |   Click to place   |   B / Esc to exit", table.concat(parts, "  "))
end

-- ── Ghost helpers ─────────────────────────────────────────────────────────
local function ensureGhost()
    if ghost then
        ghost:Destroy()
    end
    local props = GameConfig.StructureProperties[selected]
    if not props then
        return
    end
    local g = Instance.new("Part")
    g.Name = "BuildGhost"
    g.Size = props.Size
    g.Anchored = true
    g.CanCollide = false
    g.CanQuery = false -- Don't let the ghost itself trigger collision checks
    g.CanTouch = false
    g.Color = COLOR_VALID
    g.Material = Enum.Material.ForceField
    g.Transparency = GHOST_TRANSPARENCY
    g.Parent = workspace
    ghost = g
end

local function destroyGhost()
    if ghost then
        ghost:Destroy()
        ghost = nil
    end
end

-- Compute the placement CFrame from the current mouse hit point.
-- Returns (cframe, isValid). isValid is false if out of range or colliding.
local function computePlacement()
    local character = player.Character
    local rootPart = character and character.PrimaryPart
    if not rootPart then
        return nil, false
    end

    -- Raycast from the camera to find the world point under the cursor.
    -- mouse.Hit is convenient but includes the floor — we use that.
    local hit = mouse.Hit
    if not hit then
        return nil, false
    end

    local props = GameConfig.StructureProperties[selected]
    if not props then
        return nil, false
    end

    -- Sit the structure on the ground: lift by half its height.
    local position = hit.Position + Vector3.new(0, props.Size.Y * 0.5, 0)
    -- Face the structure away from the player so walls naturally block
    -- approach. Roblox's CFrame.lookAt(eye, target) points -Z toward target;
    -- the wall's "thin" axis is X for a 4×8×1 wall, so we use the player's
    -- Y rotation snapped to 90 degrees for a clean grid feel.
    local toPlayer = rootPart.Position - position
    local angleY = math.atan2(toPlayer.X, toPlayer.Z)
    local snapped = math.floor((angleY + math.pi / 4) / (math.pi / 2)) * (math.pi / 2)
    local cf = CFrame.new(position) * CFrame.fromEulerAnglesYXZ(0, snapped, 0)

    -- Range check (server uses MAX_BUILD_DISTANCE)
    local delta = position - rootPart.Position
    local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
    local inRange = distSq <= GameConfig.MAX_BUILD_DISTANCE * GameConfig.MAX_BUILD_DISTANCE

    -- Collision check (mirrors BuildingSystem.hasCollision server-side)
    overlapParams.FilterDescendantsInstances = { ghost, character }
    local insetSize = Vector3.new(
        math.max(0.1, props.Size.X - 0.2),
        math.max(0.1, props.Size.Y - 0.2),
        math.max(0.1, props.Size.Z - 0.2)
    )
    local hits = workspace:GetPartBoundsInBox(cf, insetSize, overlapParams)
    local collides = #hits > 0

    return cf, inRange and not collides
end

-- ── Build mode lifecycle ──────────────────────────────────────────────────
local function exitBuildMode()
    if not active then
        return
    end
    active = false
    destroyGhost()
    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
    if clickConn then
        clickConn:Disconnect()
        clickConn = nil
    end
    if hint then
        hint:Destroy()
        hint = nil
        hintLabel = nil
    end
    print("[BuildPlacementClient] Exited build mode.")
end

local function enterBuildMode()
    if active then
        return
    end
    active = true
    ensureGhost()

    local h, label = buildHintGui()
    hint = h
    hintLabel = label
    updateHint()

    renderConn = RunService.RenderStepped:Connect(function()
        if not ghost then
            return
        end
        local cf, valid = computePlacement()
        if cf then
            ghost.CFrame = cf
            ghost.Color = valid and COLOR_VALID or COLOR_INVALID
        end
    end)

    clickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not active then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local cf, valid = computePlacement()
            if cf and valid then
                PlaceStructureEvent:FireServer(selected, cf)
            end
            -- If invalid, swallow the click so the ghost colour is the
            -- only feedback (avoids blasting the server with rejects).
        end
    end)

    print(string.format("[BuildPlacementClient] Entered build mode. Selected: %s", selected))
end

local function selectStructure(name)
    if not GameConfig.StructureProperties[name] then
        return
    end
    selected = name
    if active then
        ensureGhost()
        updateHint()
    end
end

-- ── Toggle binding ────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.B then
        if active then
            exitBuildMode()
        else
            enterBuildMode()
        end
        return
    end
    if active and input.KeyCode == Enum.KeyCode.Escape then
        exitBuildMode()
        return
    end
    -- Number-key structure selection while in build mode.
    if active then
        local digit = input.KeyCode.Value - Enum.KeyCode.One.Value + 1
        if digit >= 1 and digit <= #STRUCTURE_ORDER then
            selectStructure(STRUCTURE_ORDER[digit])
        end
    end
end)

print("[BuildPlacementClient] Initialized. Press B to enter build mode.")
