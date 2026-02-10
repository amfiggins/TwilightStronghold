local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

print("[Verification] Starting Resource Mapping Verification...")

local invalidCount = 0

for nodeName, resourceId in pairs(GameConfig.NodeTypeMapping) do
    if not GameConfig.Resources[resourceId] then
        warn(string.format("[Verification] FAILURE: Node '%s' maps to unknown resource '%s'", nodeName, resourceId))
        invalidCount = invalidCount + 1
    end
end

if invalidCount == 0 then
    print("[Verification] SUCCESS: All Resource Mappings Valid")
else
    warn(string.format("[Verification] FAILED: %d invalid mappings found.", invalidCount))
end
