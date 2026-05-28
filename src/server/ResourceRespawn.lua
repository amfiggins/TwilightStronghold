--[[
    ResourceRespawn.lua
    Restores resource nodes (trees, rocks, ponds) some time after they're
    gathered, so the world doesn't go barren after a few minutes.

    Approach:
      - When ResourceManager wants to destroy a gathered node, it calls
        ResourceRespawn.Schedule(node, parent, cframe). Instead of an
        immediate :Destroy(), we Clone() the node into a holding folder
        in ServerStorage, then destroy the world copy.
      - After RESPAWN_MIN..RESPAWN_MAX seconds, the cloned snapshot is
        re-parented back to its original parent at its original CFrame.
      - Snapshots include the full hierarchy (children, ProximityPrompts,
        attributes) so the respawned node behaves identically.

    Why clone-and-snapshot rather than re-spawn from a template:
      - Phase 2.1 will hand-author resource nodes in Studio (.rbxm map).
        Cloning the actual instance preserves whatever the level designer
        configured (variant materials, custom prompts, decorative children).
      - It's also future-proof: when MapManager loads nodes from the map,
        we don't need a parallel "templates" folder.
]]
local ServerStorage = game:GetService("ServerStorage")

local ResourceRespawn = {}

-- ── Config ────────────────────────────────────────────────────────────────
local RESPAWN_MIN_SECONDS = 60
local RESPAWN_MAX_SECONDS = 120

-- ── Holding folder ────────────────────────────────────────────────────────
local function getHoldingFolder()
    local existing = ServerStorage:FindFirstChild("ResourceRespawnPool")
    if existing then
        return existing
    end
    local folder = Instance.new("Folder")
    folder.Name = "ResourceRespawnPool"
    folder.Parent = ServerStorage
    return folder
end

-- ── Internal ──────────────────────────────────────────────────────────────
-- Resolve a node's pivot. Models and BaseParts both work; anything else
-- is unsupported and we bail rather than silently lose the node.
local function getPivot(node)
    if node:IsA("Model") then
        return node:GetPivot()
    elseif node:IsA("BasePart") then
        return node.CFrame
    end
    return nil
end

local function setPivot(node, cframe)
    if node:IsA("Model") then
        node:PivotTo(cframe)
    elseif node:IsA("BasePart") then
        node.CFrame = cframe
    end
end

-- ── Public API ────────────────────────────────────────────────────────────

-- Schedule a node for respawn. Call this *instead of* node:Destroy() when a
-- gather succeeds. Returns true if scheduled, false if the node is invalid.
function ResourceRespawn.Schedule(node)
    if typeof(node) ~= "Instance" or not node:IsDescendantOf(workspace) then
        return false
    end

    local originalParent = node.Parent
    local originalCFrame = getPivot(node)
    if not originalParent or not originalCFrame then
        node:Destroy()
        return false
    end

    -- Clone into the holding pool BEFORE destroying the world copy so we
    -- preserve the full hierarchy (prompts, decals, attributes, etc).
    local snapshot = node:Clone()
    snapshot.Parent = getHoldingFolder()

    -- Remove from the world. The visual "depleted" effect is the immediate
    -- disappearance — we could add VFX later, but for now this matches the
    -- existing `DestroyOnGather` behaviour.
    node:Destroy()

    local respawnDelay = RESPAWN_MIN_SECONDS + math.random() * (RESPAWN_MAX_SECONDS - RESPAWN_MIN_SECONDS)

    task.delay(respawnDelay, function()
        -- Defensive: if the original parent has been destroyed (e.g., a map
        -- swap) drop the snapshot rather than re-parent into nothing.
        if not originalParent or not originalParent.Parent then
            snapshot:Destroy()
            return
        end

        setPivot(snapshot, originalCFrame)
        snapshot.Parent = originalParent
    end)

    return true
end

-- Diagnostic: how many nodes are currently waiting to respawn.
function ResourceRespawn.PendingCount()
    return #getHoldingFolder():GetChildren()
end

return ResourceRespawn
