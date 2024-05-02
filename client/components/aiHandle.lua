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
---@param light CTrafficlights
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

        if not (#(vec3(intersectionCenter.x, intersectionCenter.y, intersectionCenter.z) - aiCoords) > 5.0) then
            goto continue
        end

        CreateThread(function()
            TaskVehicleTempAction(GetPedInVehicleSeat(aiVehicle, -1), aiVehicle, 6, 1500)
            Wait(1500)

            FreezeEntityPosition(aiVehicle, true)

            SetTimeout(12000, function()
                FreezeEntityPosition(aiVehicle, false)
            end)
        end)

        ::continue::
    end
end

---@param pVehicle number
---@param light number
---@param intersectionCenter vector4
function AI:ForceDriveAtGreenLight(pVehicle, light, intersectionCenter)
    local pVehicleCoords <const> = GetEntityCoords(pVehicle)
    local pVehicleHeading <const> = GetEntityHeading(pVehicle)
    local lightCoords <const> = GetEntityCoords(light)
    local searchPoint <const> = Math.GetForwardFromCoords(vec4(lightCoords.x, lightCoords.y, lightCoords.z, GetEntityHeading(light)), 18.0, 'left')
    local vehicles <const> = Trafficlight:GetVehiclesInRange(pVehicleCoords, 35.0)
    local frontVehicles <const> = Trafficlight:GetVehiclesInRange(vec3(searchPoint.x, searchPoint.y, searchPoint.z), 20.0)

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
        local driveDistance <const> = #(vec3(intersectionCenter.x, intersectionCenter.y, intersectionCenter.z) - aiPosition)
        local targetCoords <const> = Math.GetForwardFromCoords(vec4(aiPosition.x, aiPosition.y, aiPosition.z, aiHeading), driveDistance)

        SetEntityDrawOutline(aiVehicle, true)
        SetTimeout(4000, function()
            SetEntityDrawOutline(aiVehicle, false)
        end)

        TaskVehicleDriveToCoord(aiDriver, aiVehicle, targetCoords.x, targetCoords.y, targetCoords.z, 15.0, -1, GetEntityModel(aiVehicle), 259, 7.0, 1)
        Wait(1500)

        ::continue::
    end
end