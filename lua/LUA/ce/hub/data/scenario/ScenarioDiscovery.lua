if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDiscovery ...") end

local ScenarioDiscovery = {}

local staticCameras = {}
local dynamicCameras = {}

function ScenarioDiscovery.getStaticCameras()
    return staticCameras
end

function ScenarioDiscovery.getDynamicCameras()
    return dynamicCameras
end

function ScenarioDiscovery.initFromAnl3(tableOfAnl3)
    staticCameras = {}
    dynamicCameras = {}
    if not tableOfAnl3 then return end

    local cameras = tableOfAnl3.cameras or { static = {}, dynamic = {} }

    for _, name in ipairs(cameras.static or {}) do
        if name ~= "Leer" then
            staticCameras[#staticCameras + 1] = name
        end
    end
    for _, name in ipairs(cameras.dynamic or {}) do
        if name ~= "Leer" then
            dynamicCameras[#dynamicCameras + 1] = name
        end
    end
end

return ScenarioDiscovery
