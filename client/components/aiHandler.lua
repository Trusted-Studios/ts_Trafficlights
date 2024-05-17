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

AI = {}

---@param pVehicle number
---@param light CTrafficlight
---@param intersectionCenter vector4
function AI:StopAtRedLight(pVehicle, light, intersectionCenter)
    local vehicles <const> = Trafficlight:GetVehiclesInRange(light.coords, 35.0)

    for _, aiVehicle in ipairs(vehicles) do
        if aiVehicle == pVehicle then
            goto continue
        end

        if not LightSearch:IsHeadingInRange(light.heading - 180.0, GetEntityHeading(aiVehicle), 8.0) then
            goto continue
        end

        local aiCoords <const> = GetEntityCoords(aiVehicle)
        if not LightSearch:IsInHeightRange(aiCoords, light.coords.z, 5.0) then
            goto continue
        end

        if not (#(Math.Vec4ToVec3(intersectionCenter) - aiCoords) > 5.0) then
            goto continue
        end

        CreateThread(function()
            local x, y, z = table.unpack(GetEntityCoords(aiVehicle))
            local speedZone <const> = AddSpeedZoneForCoord(x, y, z, 5.0, 0.0, false)

            SetTimeout(12000, function()
                RemoveSpeedZone(speedZone)
            end)
        end)

        ::continue::
    end
end

---@param pVehicle number
---@param light number
---@param intersectionCenter vector4
function AI:ForceDriveAtGreenLight(pVehicleCoords, pVehicleHeading, pVehicle, light, intersectionCenter)
    local lightCoords <const> = GetEntityCoords(light)
    local searchPoint <const> = Math.GetForwardFromCoords(Math.Vec3ToVec4(lightCoords, GetEntityHeading(light)), 18.0, 'left')
    local vehicles <const> = Trafficlight:GetVehiclesInRange(pVehicleCoords, 35.0)
    local frontVehicles <const> = Trafficlight:GetVehiclesInRange(Math.Vec4ToVec3(searchPoint), 20.0)

    AI:HandleDriveAtGreenLight(pVehicle, pVehicleHeading, pVehicleCoords, intersectionCenter, vehicles)
    AI:HandleDriveAtGreenLight(pVehicle, pVehicleHeading, pVehicleCoords, intersectionCenter, frontVehicles, 180.0)
end

---@param pVehicle number
---@param pVehicleHeading number
---@param pVehicleCoords vector3
---@param intersectionCenter vector4
---@param vehiclePool table
---@param angleAdjuster number?
function AI:HandleDriveAtGreenLight(pVehicle, pVehicleHeading, pVehicleCoords, intersectionCenter, vehiclePool, angleAdjuster)
    for _, aiVehicle in ipairs(vehiclePool) do
        if aiVehicle == pVehicle then
            goto continue
        end

        local aiHeading <const> = GetEntityHeading(aiVehicle)
        if not LightSearch:IsHeadingInRange(pVehicleHeading - (angleAdjuster or 0), aiHeading, 35.0) then
            goto continue
        end

        if not LightSearch:IsInHeightRange(GetEntityCoords(aiVehicle), pVehicleCoords.z, 5.0) then
            goto continue
        end

        local aiDriver <const> = GetPedInVehicleSeat(aiVehicle, -1)
        local aiPosition <const> = GetEntityCoords(aiVehicle)
        local driveDistance <const> = #(Math.Vec4ToVec3(intersectionCenter) - aiPosition)
        local targetCoords <const> = Math.GetForwardFromCoords(Math.Vec3ToVec4(aiPosition, aiHeading), driveDistance)

        if Trusted.Debug then
            SetEntityDrawOutline(aiVehicle, true)
            SetTimeout(4000, function()
                SetEntityDrawOutline(aiVehicle, false)
            end)
        end

        TaskVehicleDriveToCoord(aiDriver, aiVehicle, targetCoords.x, targetCoords.y, targetCoords.z, 15.0, -1, GetEntityModel(aiVehicle), 259, 7.0, 1)
        Wait(1500)

        ::continue::
    end
end