if AkDebugLoad then print("[#Start] Loading ce.hub.publish.ServerEventDispatcher ...") end

local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")

local ServerEventDispatcher = {}
local allowedHubCeTypes = {}

local function toLookup(list)
    local lookup = {}
    for _, ceType in pairs(list or {}) do lookup[ceType] = true end
    return lookup
end

local function shouldForwardHubCeType(ceType)
    if next(allowedHubCeTypes) == nil then return true end
    return allowedHubCeTypes[ceType] == true
end

function ServerEventDispatcher.setAllowedHubCeTypes(list)
    allowedHubCeTypes = toLookup(list)
end

function ServerEventDispatcher.fireEvent(event)
    if event.type == "CompleteReset" then
        ServerEventBuffer.fireEvent(event)
        return
    end

    local payload = event.payload or {}
    local ceType = payload.ceType
    local ceTypeDef = CeTypeRegistry.getCeTypeDefinition(ceType)
    if not ceTypeDef or ceTypeDef.owner ~= "ce.hub.mods.HubCeModule" then
        ServerEventBuffer.fireEvent(event)
        return
    end

    if shouldForwardHubCeType(ceType) then ServerEventBuffer.fireEvent(event) end
end

return ServerEventDispatcher
