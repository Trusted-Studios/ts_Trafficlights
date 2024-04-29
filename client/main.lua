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
    }
}

function Trafficlight:Main()
    local ped <const> = PlayerPedId()
    if not IsPedSittingInAnyVehicle(ped) then
        Wait(800)
        return
    end

    local vehicle <const> = GetVehiclePedIsIn(ped, false)
    if not IsVehicleStopped(vehicle) then
        Wait(800)
        return
    end

    self:Handle(ped, vehicle)
end

function Trafficlight:Handle(ped, vehicle)
    local pos <const> = GetEntityCoords(vehicle)
    local heading <const> = GetEntityHeading(vehicle)
    local targetLight = -1
    local searchDistance = -1
    for i = 60, 10, -10 do
        searchDistance = i

    end
end

function Trafficlight:GetForwardField(coords, angle, distance)

end