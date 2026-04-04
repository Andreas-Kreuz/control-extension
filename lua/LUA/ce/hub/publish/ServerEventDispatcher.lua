if AkDebugLoad then print("[#Start] Loading ce.hub.publish.ServerEventDispatcher ...") end

local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")

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
    if not ceTypeDef or ceTypeDef.owner ~= "ce.hub.CeHubModule" then
        ServerEventBuffer.fireEvent(event)
        return
    end

    if not shouldForwardHubCeType(ceType) then return end

    if ceTypeDef.isDynamic then
        local element = payload.element or {}
        local entryId = element[ceTypeDef.keyId]
        if not DynamicUpdateRegistry.isSelected(ceType, tostring(entryId or "")) then return end
    end

    ServerEventBuffer.fireEvent(event)
end

return ServerEventDispatcher
