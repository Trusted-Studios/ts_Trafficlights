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

---@param lightCoords vector3
---@param hash number
RegisterNetEvent('Trusted:Trafficlights:SyncChange', function(lightCoords, hash)
    for i = 1, #cachedLights do
        if cachedLights[i] == lightCoords then
            TriggerClientEvent('Trusted:Trafficlights:timeout', source)
            return
        end
    end

    table.insert(cachedLights, lightCoords)

    SetTimeout(18000, function()
        for i = 1, #cachedLights do
            if cachedLights[i] == lightCoords then
                table.remove(cachedLights, i)
                break
            end
        end
    end)

    TriggerClientEvent('Trusted:Trafficlights:SyncChange', -1, lightCoords, hash)
end)
