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

LightHandler = {}

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


---@todo: improve code, to be more readable
---@return table?
function LightHandler:CalculateLightPosition(light)
    local positions <const> = {
        first = {
            green = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 4,
                        light.heading
                    ), 0.53, "back"
                ), 0.2, "right"
            ),
            black = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 4.34,
                        light.heading
                    ), 0.6, "back"
                ), 0.2, "right"
            ),
            red = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 4.75,
                        light.heading
                    ), 0.6, "back"
                ), 0.2, "right"
            )
        },
        second = {
            green = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 5.7,
                        light.heading
                    ), 0.53, "back"
                ), 4.79, "left"
            ),
            black = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.14,
                        light.heading
                    ), 0.6, "back"
                ), 4.79, "left"
            ),
            red = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.5,
                        light.heading
                    ), 0.6, "back"
                ), 4.79, "left"
            )
        },
        thrid = {
            green = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 5.95,
                        light.heading
                    ), 0.53, "back"
                ), 9.48, "left"
            ),
            black = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.3,
                        light.heading
                    ), 0.6, "back"
                ), 9.48, "left"
            ),
            red = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.7,
                        light.heading
                    ), 0.6, "back"
                ), 9.48, "left"
            )
        },
        fourth = {
            green = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 5.95,
                        light.heading
                    ), 0.53, "back"
                ), 10, "left"
            ),
            black = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.3,
                        light.heading
                    ), 0.6, "back"
                ), 10, "left"
            ),
            red = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 6.7,
                        light.heading
                    ), 0.6, "back"
                ), 10, "left"
            )
        },
        fifth = {
            green = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 3,
                        light.heading
                    ), 0.33, "back"
                ), 0.35, "left"
            ),
            black = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 3.34,
                        light.heading
                    ), 0.4, "back"
                ), 0.35, "left"
            ),
            red = Math.GetForwardFromCoords(
                Math.GetForwardFromCoords(
                    vec4(
                        light.coords.x,
                        light.coords.y,
                        light.coords.z + 3.75,
                        light.heading
                    ), 0.4, "back"
                ), 0.35, "left"
            )
        }
    }

    if light.hash == GetHashKey("prop_traffic_01a") then
        return {
            first = positions.first,
            second = positions.second,
        }
    end

    if light.hash == GetHashKey("prop_traffic_01b") then
        return {
            first = positions.first,
            second = positions.second,
            thrid = positions.thrid,
        }
    end

    if light.hash == GetHashKey("prop_traffic_01d") then
        return {
            first = positions.first,
            second = positions.second,
            thrid = positions.thrid,
            fourth = positions.fourth,
        }
    end

    if light.hash == GetHashKey("prop_traffic_03a") then
        return {
            fifth = positions.fifth,
        }
    end
end

function LightHandler:DrawGreenLight(coords)
    self:DrawVerticalCircle(coords, 0.15, 53, 227, 189, 255)
end

function LightHandler:DrawRedLight(coords)
    self:DrawVerticalCircle(coords, 0.2, 255, 51, 51, 255)
end

function LightHandler:DrawOutLight(coords)
    self:DrawVerticalCircle(coords, 0.2, 28, 34, 40, 255)
end

function LightHandler:DrawLights(hash, lightCoords)
    if hash == GetHashKey("prop_traffic_01a") then
        self:DrawGreenLight(lightCoords.first.green)
        self:DrawOutLight(lightCoords.first.black)
        self:DrawOutLight(lightCoords.first.red)

        self:DrawGreenLight(lightCoords.second.green)
        self:DrawOutLight(lightCoords.second.black)
        self:DrawOutLight(lightCoords.second.red)
    end

    if hash == GetHashKey("prop_traffic_01b") then
        self:DrawGreenLight(lightCoords.first.green)
        self:DrawOutLight(lightCoords.first.black)
        self:DrawOutLight(lightCoords.first.red)

        self:DrawGreenLight(lightCoords.second.green)
        self:DrawOutLight(lightCoords.second.black)
        self:DrawOutLight(lightCoords.second.red)

        self:DrawGreenLight(lightCoords.thrid.green)
        self:DrawOutLight(lightCoords.thrid.black)
        self:DrawOutLight(lightCoords.thrid.red)
    end

    if hash == GetHashKey("prop_traffic_01d") then
        self:DrawGreenLight(lightCoords.first.green)
        self:DrawOutLight(lightCoords.first.black)
        self:DrawOutLight(lightCoords.first.red)

        self:DrawGreenLight(lightCoords.second.green)
        self:DrawOutLight(lightCoords.second.black)
        self:DrawOutLight(lightCoords.second.red)

        self:DrawGreenLight(lightCoords.thrid.green)
        self:DrawOutLight(lightCoords.thrid.black)
        self:DrawOutLight(lightCoords.thrid.red)

        self:DrawGreenLight(lightCoords.fourth.green)
        self:DrawOutLight(lightCoords.fourth.black)
        self:DrawOutLight(lightCoords.fourth.red)
    end

    if hash == GetHashKey("prop_traffic_03a") then
        self:DrawGreenLight(lightCoords.fifth.green)
        self:DrawOutLight(lightCoords.fifth.black)
        self:DrawOutLight(lightCoords.fifth.red)
    end

    return true
end

function LightHandler:Handle(light, duration, lightEntity)
    local ped <const> = PlayerPedId()
    local draw = true
    CreateThread(function()
        local lightCoords <const> = LightHandler:CalculateLightPosition(light)

        if lightCoords == nil then
            return
        end

        while draw do
            Wait(10)
            local coords = GetEntityCoords(ped)

            if #(coords - light.coords) < 70.0 then
                Wait(500)
                SetEntityTrafficlightOverride(lightEntity, 0)
                goto continue
            end

            if #(coords - light.coords) > 250.0 then
                Wait(500)
                goto continue
            end

            ---@todo: add feature to only draw lights when player is looking at the traffic lights

            LightHandler:DrawLights(light.hash, lightCoords)

            ::continue::
        end
    end)

    SetTimeout(duration, function()
        draw = false
    end)
end