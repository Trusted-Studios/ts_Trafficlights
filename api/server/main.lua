-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Debug Logs
-- ════════════════════════════════════════════════════════════════════════════════════ --

local filename = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("^.*/(.*).lua$") or str
end
print("^6[API -> SERVER - DEBUG] ^0: "..filename()..".lua gestartet");

-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Code
-- ════════════════════════════════════════════════════════════════════════════════════ --

API = {
    usedIntersections = {}
}

RegisterNetEvent('Trusted:Trafficlight:API:SyncChange', function(heading, lights, intersectionCenter, radius, duration)
    API.usedIntersections[intersectionCenter] = true

    local frontLights <const> = {}
    local parallelLights <const> = {}
    local otherLights <const> = {}

    for i = 1, #lights do
        if IsHeadingInRange(heading, lights[i].heading, 25.0) then
            table.insert(frontLights, lights[i])
            goto continue
        end

        if IsHeadingInRange(heading + 180.0, lights[i].heading, 25.0) then
            table.insert(parallelLights, lights[i])
            goto continue
        end

        table.insert(otherLights, lights[i])

        ::continue::
    end

    TriggerClientEvent('Trusted:Trafficlight:API:SyncChange', -1, frontLights, parallelLights, otherLights, duration)
    TriggerClientEvent('Trusted:Trafficlight:API:SyncAI', -1, intersectionCenter, radius, heading, duration)
end)