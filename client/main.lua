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

Trafficlight = {
    hash = {
        GetHashKey("prop_traffic_01a"),
        GetHashKey("prop_traffic_01b"),
        GetHashKey("prop_traffic_01d"),
        GetHashKey("prop_traffic_02a"),
        GetHashKey("prop_traffic_02b"),
        GetHashKey("prop_traffic_03a"),
        GetHashKey("prop_traffic_03b"),
    },
    lastTargetLight = -1,
    lightFound = false,
    noLightInArea = false
}

function Trafficlight:Main()
    local ped <const> = PlayerPedId()
    if not IsPedSittingInAnyVehicle(ped) then
        if Trusted.Debug then
            print('Player is not in a vehicle.')
        end
        Wait(800)
        return
    end

    local vehicle <const> = GetVehiclePedIsIn(ped, false)
    if not IsVehicleStopped(vehicle) then
        if Trusted.Debug then
            print('vehicle is not stopped.')
        end
        self.noLightInArea = false
        Wait(800)
        return
    end

    if self.lightFound or self.noLightInArea then
        if Trusted.Debug then
            print('Trafficlight is already found.')
        end
        Wait(800)
        return
    end

    self:Handle(vehicle)
end

--- Handles object search and state sync.
---@param vehicle number
function Trafficlight:Handle(vehicle)
    local pos <const> = GetEntityCoords(vehicle)
    local heading <const> = GetEntityHeading(vehicle)
    local targetLight = 0
    local searchPosition = vector3(0.0, 0.0, 0.0)
    local foundHash = -1
    for searchDistance = 65, 5, -10 do
        searchPosition = Math.GetOffsetPositionByAngle(pos, heading, searchDistance)
        for i = 1, #self.hash do
            targetLight = GetClosestObjectOfType(searchPosition.x, searchPosition.y, searchPosition.z, 10.0, self.hash[i], false, false, false)
            if targetLight ~= 0 then
                local targetLightHeading <const> = GetEntityHeading(targetLight)
                local headingDiff <const> = Math.Round(math.abs(heading - targetLightHeading))
                if not (headingDiff < 25.0 or headingDiff > (360.0 - 25.0)) then
                    targetLight = 0
                end

                -- if Trusted.Debug then
                    if targetLight ~= 0 then
                        SetEntityDrawOutline(targetLight, true)
                        SetTimeout(10000, function()
                            SetEntityDrawOutline(targetLight, false)
                        end)
                        foundHash = self.hash[i]
                    end
                -- end

                break
            end
        end

        if targetLight ~= 0 then
            break
        end
    end

    if targetLight ~= 0 then
        self.lightFound = true
        SetTimeout(8000, function()
            Trafficlight.lightFound = false
        end)

        Wait(Config.RedLightDurationWhileWaiting)
        local lightCoords <const> = GetEntityCoords(targetLight)
        TriggerServerEvent('Trusted:Trafficlights:SyncChange', lightCoords, foundHash)
        return
    end

    self.noLightInArea = true
end

--- Handles AI to drive when lights turn green.
---@param lightCoords vector3
function Trafficlight:MoveAI(lightCoords)
    local ped <const> = PlayerPedId()
    local vehicles <const> = Trafficlight:GetVehiclesInRange(ped)
    local vehicle <const> = GetVehiclePedIsIn(ped, false)
    local pos <const> = GetEntityCoords(vehicle)
    local heading <const> = GetEntityHeading(vehicle)

    for i = 1, #vehicles do
        local aiVehicle <const> = vehicles[i]
        local aiVehiclePos <const> = GetEntityCoords(aiVehicle)
        local aiVehicleHeading <const> = GetEntityHeading(aiVehicle)
        local aiVehicleDriver <const> = GetPedInVehicleSeat(aiVehicle, -1)
        Wait(10)
        ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
        if aiVehicle ~= vehicle and Vdist(aiVehiclePos, pos) < 50.0 then
            local headingDiff <const> = Math.Round(math.abs(heading - aiVehicleHeading))
            if headingDiff < 25.0 or headingDiff > (360.0 - 25.0) then
                TaskVehicleDriveToCoord(
                    aiVehicleDriver,
                    aiVehicle,
                    lightCoords.x,
                    lightCoords.y,
                    lightCoords.z,
                    20.0,
                    -1,
                    GetEntityModel(aiVehicle),
                    259,
                    18.0,
                    1
                )

                SetTimeout(1800, function()
                    ClearPedTasks(aiVehicleDriver)
                end)
            end
        end
    end
end

function Trafficlight:GetVehiclesInRange(ped)
    local nearbyVehicles <const> = {}
    local vehicles <const> = GetGamePool('CVehicle')
    local pos <const> = GetEntityCoords(ped)

    for _, vehicle in ipairs(vehicles) do
        local distance = #(pos - GetEntityCoords(vehicle))

        if distance <= 35.0 then
            nearbyVehicles[#nearbyVehicles + 1] = vehicle
        end
    end

    return nearbyVehicles
end

--- changes the entity light state for everyone.
---@param lightCoords vector3
RegisterNetEvent('Trusted:Trafficlights:SyncChange',function(lightCoords, hash)
    local targetLight <const> = GetClosestObjectOfType(lightCoords.x, lightCoords.y, lightCoords.z, 2.0, hash, false, false, false)
    SetEntityTrafficlightOverride(targetLight, 0)
    print('changing light state to green.')

    Trafficlight:MoveAI(lightCoords)
    Wait(8000)

    SetEntityTrafficlightOverride(targetLight, 2)
    Wait(1000)
    SetEntityTrafficlightOverride(targetLight, 3)
end)

RegisterNetEvent('Trusted:Trafficlights:timeout', function()
    Trafficlight.lightFound = true
    SetTimeout(8000, function()
        Trafficlight.lightFound = false
    end)
end)

CreateThread(function()
    while true do
        Trafficlight:Main()
        Wait(0)
    end
end)