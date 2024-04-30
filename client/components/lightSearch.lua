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

LightSearch = {
    hash = {
        GetHashKey("prop_traffic_01a"),
        GetHashKey("prop_traffic_01b"),
        GetHashKey("prop_traffic_01d"),
        GetHashKey("prop_traffic_02a"),
        GetHashKey("prop_traffic_02b"),
        GetHashKey("prop_traffic_03a"),
        GetHashKey("prop_traffic_03b"),
    },
}

---@param centerCoords any
---@param lightCoords any
function LightSearch:GetIntersectionCenter(centerCoords, lightCoords)
    local distance <const> = #(lightCoords - centerCoords)
    local intersectionCenter <const> = Math.GetForwardFromCoords(centerCoords, distance / 2, 'front')

    local x, y, z = table.unpack(intersectionCenter)
    CreateThread(function()
        while true do
            Wait(0)
            Game.AddMarker(x, y, z + 1)
        end
    end)
end

--- Searches the road center using the given coords and heading.
---@param coords vector3
---@param heading number
---@return vector4?
function LightSearch:GetRoadCenter(coords, heading)
    local rExists, rRoadBoundary = GetRoadBoundaryUsingHeading(coords.x, coords.y, coords.z, heading)
    local lExists, lRoadBoundary = GetRoadBoundaryUsingHeading(coords.x, coords.y, coords.z, heading + 180.0)

    if not rExists or not lExists then
        print('^1[WARNING]^0 - Unable to find road boundaries.')
        return
    end

    print(#(rRoadBoundary - lRoadBoundary))

    if #(lRoadBoundary - rRoadBoundary) < 1.0 then
        print("^1[WARNING]^0 - Road boundaries are too close.")
        lRoadBoundary = Math.GetForwardFromCoords(vec4(rRoadBoundary.x, rRoadBoundary.y, rRoadBoundary.z, heading), 20.0, 'left')
    end

    CreateThread(function()
        local x, y, z = table.unpack(rRoadBoundary)
        while true do
            Wait(0)
            Game.AddMarker(x, y, z + 1)
        end
    end)

    CreateThread(function()
        local x, y, z = table.unpack(lRoadBoundary)
        while true do
            Wait(0)
            Game.AddMarker(x, y, z + 1)
        end
    end)

    CreateThread(function()
        while true do
            Wait(0)
            DrawLine(rRoadBoundary.x, rRoadBoundary.y, rRoadBoundary.z + 3, lRoadBoundary.x, lRoadBoundary.y, lRoadBoundary.z + 3, 255, 0, 0, 255)
        end
    end)

    local center = vec4(
        (rRoadBoundary.x + lRoadBoundary.x) / 2,
        (rRoadBoundary.y + lRoadBoundary.y) / 2,
        (rRoadBoundary.z + lRoadBoundary.z) / 2,
        heading
    )

    return center
end

--- Searches the farthest traffic light in front of the vehicle.
---@param coords vector3
---@param heading number
---@return number?, number?, vector4?
function LightSearch:GetFarFrontLight(coords, heading)
    local targetLight = 0
    local foundHash = -1
    local searchPosition = vec3(0.0, 0.0, 0.0)

    for searchDistance = 65, 15, -10 do
        searchPosition = Math.GetOffsetPositionByAngle(coords, heading, searchDistance)
        for i = 1, #self.hash do
            targetLight = GetClosestObjectOfType(searchPosition.x, searchPosition.y, searchPosition.z, 10.0, self.hash[i], false, false, false)

            if targetLight ~= 0 then
                local targetLightHeading <const> = GetEntityHeading(targetLight)
                local headingDiff <const> = Math.Round(math.abs(heading - targetLightHeading))

                if not (headingDiff < 25.0 or headingDiff > (360.0 - 25.0)) then
                    goto continue
                end

                SetEntityDrawOutline(targetLight, true)
                SetTimeout(8000, function()
                    SetEntityDrawOutline(targetLight, false)
                end)

                foundHash = self.hash[i]

                break
            end

            ::continue::
        end

        if targetLight ~= 0 then
            break
        end
    end

    if targetLight == 0 then
        return
    end

    local x, y, z = table.unpack(GetEntityCoords(targetLight))
    CreateThread(function()
        while true do
            Wait(0)
            Game.AddMarker(x, y, z + 1)
        end
    end)

    return targetLight, foundHash, vec4(x, y, z, heading)
end

-- CreateThread(function()
--     local coords = GetEntityCoords(PlayerPedId())
--     local heading = GetEntityHeading(PlayerPedId())

--     local centerCoords = LightSearch:GetRoadCenter(coords, heading)
--     local targetLight, hash, lightCoords = LightSearch:GetFarFrontLight(coords, heading)

--     LightSearch:GetIntersectionCenter(centerCoords, lightCoords)
-- end)