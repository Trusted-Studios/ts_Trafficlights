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
    local coords <const> = GetEntityCoords(vehicle)
    local heading <const> = GetEntityHeading(vehicle)

    local centerCoords <const> = LightSearch:GetRoadCenter(coords, heading)
    local targetLight <const>, lightCoords <const> = LightSearch:GetFarFrontLight(coords, heading)

    if not targetLight then
        if Trusted.Debug then
            print('^1[WARNING]^0 - No front trafficlight found.')
        end
        self.noLightInArea = true
        return
    end

    local intersectionCenter <const> = LightSearch:GetIntersectionCenter(centerCoords, lightCoords)
    local lights <const> = LightSearch:GetLightsInRange(intersectionCenter)

    if Trusted.Debug then
        for i = 1, #lights do
            SetEntityDrawOutline(lights[i].entity, true)
        end
    end

    self.lightFound = true
    SetTimeout(8000, function()
        self.lightFound = false
    end)

    TriggerServerEvent('Trusted:Trafficlights:SyncChange', coords, heading, lights, intersectionCenter, targetLight)
end

---@param coords vector3
---@param range number
---@return table
function Trafficlight:GetVehiclesInRange(coords, range)
    local nearbyVehicles <const> = {}
    local vehicles <const> = GetGamePool('CVehicle')

    for _, vehicle in ipairs(vehicles) do
        local distance = #(coords - GetEntityCoords(vehicle))

        if distance <= range then
            nearbyVehicles[#nearbyVehicles + 1] = vehicle
        end
    end

    return nearbyVehicles
end

--- changes the intersection light states.
---@param frontLights CTrafficlights[]
---@param parallelLights CTrafficlights[]
---@param otherLights CTrafficlights[]
RegisterNetEvent('Trusted:Trafficlights:SyncChange',function(frontLights, parallelLights, otherLights)
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

        SetEntityTrafficlightOverride(targetLight, 0)
    end

    for i = 1, #parallelLights do
        local x, y, z = table.unpack(parallelLights[i].coords)
        local targetLight <const> = GetClosestObjectOfType(x, y, z, 2.0, parallelLights[i].hash, false, false, false)
        lights[#lights + 1] = targetLight

        SetEntityTrafficlightOverride(targetLight, 0)
    end

    Wait(8000)

    for i = 1, #lights do
        SetEntityTrafficlightOverride(lights[i], -1)
    end
end)

--- Handles AI to drive when lights turn green.
---@param otherLights CTrafficlights[]
---@param intersectionCenter vector4
RegisterNetEvent('Trusted:Trafficlights:HandleAI', function(coords, heading, otherLights, targetLight, intersectionCenter)
    local pVehicle <const> = GetVehiclePedIsIn(PlayerPedId(), false)

    for i = 1, #otherLights do
        AI:StopAtRedLight(pVehicle, otherLights[i], intersectionCenter)
    end

    Wait(Config.RedLightDurationWhileWaiting)
    AI:ForceDriveAtGreenLight(coords, heading, pVehicle, targetLight, intersectionCenter)
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