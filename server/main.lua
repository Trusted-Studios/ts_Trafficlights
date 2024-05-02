-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Debug Logs
-- ════════════════════════════════════════════════════════════════════════════════════ --

local filename = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("^.*/(.*).lua$") or str
end
print("^6[SERVER - DEBUG] ^0: "..filename()..".lua gestartet");

-- ════════════════════════════════════════════════════════════════════════════════════ --
-- Code
-- ════════════════════════════════════════════════════════════════════════════════════ --

local cachedLights = {}

---@param triggerHeading number
---@param lights CTrafficlights[]
---@param intersectionCenter vector3
---@param targetLight number
RegisterNetEvent('Trusted:Trafficlights:SyncChange', function(triggerHeading, lights, intersectionCenter, targetLight)

    --> check if lights are cached
    for i = 1, #lights do
        if cachedLights[lights[i].coords] then
            TriggerClientEvent('Trusted:Trafficlights:timeout', source)
            return
        end
    end

    --> cache lights
    for i = 1, #lights do
        cachedLights[lights[i].coords] = lights[i].hash
    end

    --> free cache after 10 seconds
    SetTimeout(10000, function()
        for i = 1, #lights do
            cachedLights[lights[i].coords] = nil
        end
    end)

    local frontLights <const> = {}
    local parallelLights <const> = {}
    local otherLights <const> = {}

    for i = 1, #lights do
        if IsHeadingInRange(triggerHeading, lights[i].heading, 25.0) then
            table.insert(frontLights, lights[i])
            goto continue
        end

        if IsHeadingInRange(triggerHeading + 180.0, lights[i].heading, 25.0) then
            table.insert(parallelLights, lights[i])
            goto continue
        end

        table.insert(otherLights, lights[i])

        ::continue::
    end

    TriggerClientEvent('Trusted:Trafficlights:SyncChange', -1, frontLights, parallelLights, otherLights)
    TriggerClientEvent('Trusted:Trafficlights:HandleAI', source, otherLights, targetLight, intersectionCenter)
end)

---@param targetHeading number
---@param heading number
---@param range number
---@return boolean
function IsHeadingInRange(targetHeading, heading, range)
    local headingDiff <const> = Math.Round(math.abs(targetHeading - heading))
    return (headingDiff < range or headingDiff > (360.0 - range))
end