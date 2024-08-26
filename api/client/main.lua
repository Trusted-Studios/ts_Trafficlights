-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Debug Logs
-- ════════════════════════════════════════════════════════════════════════════════════ --

local filename = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("^.*/(.*).lua$") or str
end
print("^6[API -> CLIENT - DEBUG] ^0: "..filename()..".lua gestartet");

-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Code
-- ════════════════════════════════════════════════════════════════════════════════════ --

repeat Wait(0) until Trafficlight

Trafficlight.API = {}

function Trafficlight.API:SwitchLightStates(intersectionCenter, radius, heading, duration)
    local lights <const> = LightSearch:GetLightsInRange(Math.Vec4ToVec3(intersectionCenter))

    if true then
        for i = 1, #lights do
            SetEntityDrawOutline(lights[i].entity, true)
        end
    end

    TriggerServerEvent('Trusted:Trafficlight:API:SyncChange', heading, lights, intersectionCenter, radius, duration)
end

RegisterNetEvent('Trusted:Trafficlight:API:SyncChange', function(frontLights, parallelLights, otherLights, duration)
    local lights <const> = {}

    for i = 1, #otherLights do
        CreateThread(function()
            local x, y, z = table.unpack(otherLights[i].coords)
            local targetLight <const> = GetClosestObjectOfType(x, y, z, 2.0, otherLights[i].hash, false, false, false)
            lights[#lights + 1] = targetLight

            SetEntityTrafficlightOverride(targetLight, 2)
            Wait(1500)
            SetEntityTrafficlightOverride(targetLight, 1)
        end)
    end

    Wait(Config.RedLightDurationWhileWaiting)

    for i = 1, #frontLights do
        local x, y, z = table.unpack(frontLights[i].coords)
        local targetLight <const> = GetClosestObjectOfType(x, y, z, 2.0, frontLights[i].hash, false, false, false)
        lights[#lights + 1] = targetLight

        LightHandler:Handle(frontLights[i], duration)

        SetEntityTrafficlightOverride(targetLight, 0)
    end

    for i = 1, #parallelLights do
        local x, y, z = table.unpack(parallelLights[i].coords)
        local targetLight <const> = GetClosestObjectOfType(x, y, z, 2.0, parallelLights[i].hash, false, false, false)
        lights[#lights + 1] = targetLight

        LightHandler:Handle(parallelLights[i], duration)

        SetEntityTrafficlightOverride(targetLight, 0)
    end

    Wait(duration)

    for i = 1, #lights do
        SetEntityTrafficlightOverride(lights[i], -1)
    end
end)

RegisterNetEvent('Trusted:Trafficlight:API:SyncAI', function(intersectionCenter, radius, heading, duration)
    print(duration)

    local aiVehicles <const> = Trafficlight:GetVehiclesInRange(intersectionCenter, radius)

    for _, aiVehicle in ipairs(aiVehicles) do
        local aiHeading <const> = GetEntityHeading(aiVehicle)

        if LightSearch:IsInHeightRange(GetEntityCoords(aiVehicle), intersectionCenter.z, 5.0) then
            goto continue
        end

        local aiDriver <const> = GetPedInVehicleSeat(aiVehicle, -1)
        local drive <const> = LightSearch:IsHeadingInRange(heading - 180.0, aiHeading, 35.0) or LightSearch:IsHeadingInRange(heading, aiHeading, 35.0)

        if drive then
            local aiPosition <const> = GetEntityCoords(aiVehicle)
            local driveDistance <const> = #(Math.Vec4ToVec3(intersectionCenter) - aiPosition)
            local targetCoords <const> = Math.GetForwardFromCoords(Math.Vec3ToVec4(aiPosition, aiHeading), driveDistance)

            TaskVehicleDriveToCoord(aiDriver, aiVehicle, targetCoords.x, targetCoords.y, targetCoords.z, 15, -1, GetEntityModel(aiVehicle), 259, 7.0, 1)

            goto continue
        end

        TaskVehicleTempAction(aiDriver, aiVehicle, 1, 1500)
        Wait(1500)
        FreezeEntityPosition(aiVehicle, true)

        SetTimeout(duration, function()
            FreezeEntityPosition(aiVehicle, false)
        end)

        ::continue::
    end
end)

exports("SwitchLightStates", function(intersectionCenter, radius, heading, durarion)
    Trafficlight.API:SwitchLightStates(intersectionCenter, radius, heading, durarion)
end)