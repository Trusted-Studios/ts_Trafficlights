-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Debug Logs
-- ════════════════════════════════════════════════════════════════════════════════════ --

local filename = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("^.*/(.*).lua$") or str
end
print("^6[CLIENT - DEBUG] ^0: "..filename()..".lua gestartet");

-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Code
-- ════════════════════════════════════════════════════════════════════════════════════ --

local LightHandler = {}

function LightHandler:DrawVerticalCircle(coords, radius, red, green, blue, alpha)
    local centerX, centerY, centerZ, angleZ = table.unpack(coords)
    local numSegments <const> = 10
    local angleStep <const> = 2 * math.pi / numSegments

    local angleZRad <const> = math.rad(angleZ - 90.0)

    local cosZ <const> = math.cos(angleZRad)
    local sinZ <const> = math.sin(angleZRad)

    for i = 0, numSegments - 1 do
        local theta1 <const> = i * angleStep
        local theta2 <const> = (i + 1) * angleStep

        local x1 <const> = 0
        local y1 <const> = radius * math.cos(theta1)
        local z1 <const> = radius * math.sin(theta1)

        local x2 <const> = 0
        local y2 <const> = radius * math.cos(theta2)
        local z2 <const> = radius * math.sin(theta2)

        local rotatedX1 <const> = centerX + x1 * cosZ - y1 * sinZ
        local rotatedY1 <const> = centerY + x1 * sinZ + y1 * cosZ
        local rotatedZ1 <const> = centerZ + z1

        local rotatedX2 <const> = centerX + x2 * cosZ - y2 * sinZ
        local rotatedY2 <const> = centerY + x2 * sinZ + y2 * cosZ
        local rotatedZ2 <const> = centerZ + z2

        DrawPoly(centerX, centerY, centerZ, rotatedX1, rotatedY1, rotatedZ1, rotatedX2, rotatedY2, rotatedZ2, red, green, blue, alpha)
    end
end

---@return table?
function LightHandler:CalculateLightPosition(light)
    print(light.hash, GetHashKey("prop_traffic_01b"))
    if light.hash == GetHashKey("prop_traffic_01b") then
        return {
            vec4(light.coords.x, light.coords.y, light.coords.z + 1.0, light.heading)
        }
    end
end

function LightHandler:DrawGreenLight(coords)
    self:DrawVerticalCircle(coords, 0.1, 53, 227, 189, 255)
end

function LightHandler:DrawRedLight(coords)
    self:DrawVerticalCircle(coords, 0.1, 241, 94, 94, 255)
end

function LightHandler:DrawOutLight(coords)
    self:DrawVerticalCircle(coords, 0.1, 53, 61, 74, 255)
end

CreateThread(function()
    -- local ped = PlayerPedId()
    -- local lights = LightSearch:GetLightsInRange(GetEntityCoords(ped))

    -- local lightCoords = LightHandler:CalculateLightPosition(lights[1])

    -- if not lightCoords then
    --     return
    -- end

    -- SetEntityCoords(ped, lightCoords[1])

    while true do
        Wait(0)
        -- for i = 1, #lightCoords do
        --     LightHandler:DrawGreenLight(lightCoords[i])
        -- end
        LightHandler:DrawGreenLight(vec4(241.20, -1426.41, 29.29, 252.52))
        LightHandler:DrawRedLight(vec4(242.01, -1425.77, 29.28, 232.56))
        LightHandler:DrawOutLight(vec4(242.90, -1424.82, 29.30, 232.67))
    end
end)