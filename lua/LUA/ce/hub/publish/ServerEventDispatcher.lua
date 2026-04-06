if AkDebugLoad then print("[#Start] Loading ce.hub.publish.ServerEventDispatcher ...") end

local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local ServerEventDispatcher = {}
local ceTypeModes = {}

function ServerEventDispatcher.setCeTypeModes(modes)
    ceTypeModes = {}
    for ceType, mode in pairs(modes or {}) do
        ceTypeModes[ceType] = mode
    end
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

    local syncMode = SyncPolicy.normalizeMode(ceTypeModes[ceType], ceTypeDef.isDynamic)
    if syncMode == "none" then return end

    if ceTypeDef.isDynamic and syncMode == "selected" then
        local element = payload.element or {}
        local entryId = element[ceTypeDef.keyId]
        if not DynamicUpdateRegistry.isSelected(ceType, tostring(entryId or "")) then return end
    end

    ServerEventBuffer.fireEvent(event)
end

return ServerEventDispatcher
