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
    hashIndexList = {
        [GetHashKey("prop_traffic_01a")] = true,
        [GetHashKey("prop_traffic_01b")] = true,
        [GetHashKey("prop_traffic_01d")] = true,
        [GetHashKey("prop_traffic_02a")] = true,
        [GetHashKey("prop_traffic_02b")] = true,
        [GetHashKey("prop_traffic_03a")] = true,
        [GetHashKey("prop_traffic_03b")] = true,
    }
}

---@param centerCoords any
---@param lightCoords any
---@return vector4
function LightSearch:GetIntersectionCenter(centerCoords, lightCoords)
    local distance <const> = #(lightCoords - centerCoords)

    return Math.GetForwardFromCoords(centerCoords, distance / 2, 'front')
end

--- Searches the road center using the given coords and heading.
---@param coords vector3
---@param heading number
---@return vector4?
function LightSearch:GetRoadCenter(coords, heading)
    local rExists, rRoadBoundary = GetRoadBoundaryUsingHeading(coords.x, coords.y, coords.z, heading)
    local lExists, lRoadBoundary = GetRoadBoundaryUsingHeading(coords.x, coords.y, coords.z, heading + 180.0)

    if not rExists or not lExists then
        if Trusted.Debug then
            print('^1[WARNING]^0 - Unable to find road boundaries.')
        end
        return
    end

    if #(lRoadBoundary - rRoadBoundary) < 1.0 then
        if Trusted.Debug then
            print("^1[WARNING]^0 - Road boundaries are too close.")
        end
        lRoadBoundary = Math.GetForwardFromCoords(vec4(rRoadBoundary.x, rRoadBoundary.y, rRoadBoundary.z, heading), 20.0, 'left')
    end

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
---@return number?, vector4?
function LightSearch:GetFarFrontLight(coords, heading)
    local targetLight = 0
    local searchPosition = vec3(0.0, 0.0, 0.0)

    for searchDistance = 65, 15, -10 do
        searchPosition = Math.GetOffsetPositionByAngle(coords, heading, searchDistance)
        for i = 1, #self.hash do
            targetLight = GetClosestObjectOfType(searchPosition.x, searchPosition.y, searchPosition.z, 15.0, self.hash[i], false, false, false)

            if targetLight ~= 0 then
                local targetLightHeading <const> = GetEntityHeading(targetLight)

                if not LightSearch:IsHeadingInRange(heading, targetLightHeading, 25.0) then
                    goto continue
                end

                if Trusted.Debug then
                    SetEntityDrawOutline(targetLight, true)
                    SetTimeout(8000, function()
                        SetEntityDrawOutline(targetLight, false)
                    end)
                end

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

    return targetLight, vec4(x, y, z, heading)
end

---@param coords vector3
---@return CTrafficlights[]
function LightSearch:GetLightsInRange(coords)
    local nearbyLights <const> = {}
    local entities <const> = GetGamePool('CObject')

    for _, entity in ipairs(entities) do

        if not self.hashIndexList[GetEntityModel(entity)] then
            goto continue
        end

        local lightCoords <const> = GetEntityCoords(entity)
        local distance <const> = #(vec3(coords.x, coords.y, coords.z) - lightCoords)

        if distance <= 40.0 and LightSearch:IsInHeightRange(lightCoords, coords.z, 2.5) then
            nearbyLights[#nearbyLights + 1] = {
                entity = entity,
                coords = lightCoords,
                hash = GetEntityModel(entity),
                heading = GetEntityHeading(entity)
            }
        end

        ::continue::
    end

    return nearbyLights
end

---@todo? move to math lib
---@param targetHeading number
---@param heading number
---@param range number
---@return boolean
function LightSearch:IsHeadingInRange(targetHeading, heading, range)
    local headingDiff <const> = Math.Round(math.abs(targetHeading - heading))
    return (headingDiff < range or headingDiff > (360.0 - range))
end

---@param coords vector3
---@param height number
---@param range number
---@return boolean
function LightSearch:IsInHeightRange(coords, height, range)
    return math.abs(coords.z - height) < range
end