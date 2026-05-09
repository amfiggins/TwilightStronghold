local function getComponents()
    return 0,0,0, 1,0,0, 0,1,0, 0,0,1
end

local start = os.clock()
for i = 1, 10000000 do
    local components = {getComponents()}
    for _, v in ipairs(components) do
        if v ~= v or math.abs(v) == math.huge then
            break
        end
    end
end
print("Table:", os.clock() - start)

local start2 = os.clock()
for i = 1, 10000000 do
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = getComponents()
    if x ~= x or math.abs(x) == math.huge or
       y ~= y or math.abs(y) == math.huge or
       z ~= z or math.abs(z) == math.huge or
       r00 ~= r00 or math.abs(r00) == math.huge or
       r01 ~= r01 or math.abs(r01) == math.huge or
       r02 ~= r02 or math.abs(r02) == math.huge or
       r10 ~= r10 or math.abs(r10) == math.huge or
       r11 ~= r11 or math.abs(r11) == math.huge or
       r12 ~= r12 or math.abs(r12) == math.huge or
       r20 ~= r20 or math.abs(r20) == math.huge or
       r21 ~= r21 or math.abs(r21) == math.huge or
       r22 ~= r22 or math.abs(r22) == math.huge then
        -- fail
    end
end
print("Vars:", os.clock() - start2)
