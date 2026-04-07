if CeDebugLoad then print("[#Start] Loading ce.hub.publish.DataChangeBus ...") end
local TableUtils = require("ce.hub.util.TableUtils")

local DataChangeBus = {}
local listeners = {}
DataChangeBus.debug = CeStartWithDebug or false
local initialized = false
local eventCounter = 0

DataChangeBus.eventType = {
    completeReset = "CompleteReset",
    dataAdded = "DataAdded",
    dataChanged = "DataChanged",
    listChanged = "ListChanged",
    dataRemoved = "DataRemoved"
}

DataChangeBus.printListener = {
    fireEvent = function (event)
        local payload = event.payload
        local t = type(payload)
        if t == "table" then
            if event.type == "ListChanged" then
                t = payload.ceType .. ": " .. t .. " with " .. TableUtils.length(payload.list) .. " entries"
            elseif event.type == "CompleteReset" then
                t = t .. ": " .. payload.info
            else
                t = payload.ceType .. ": " .. t
            end
        else
            t = t .. ": " .. tostring(payload)
        end
        print("[#EventCounter] " .. event.eventCounter .. ": " .. event.type .. " .. " .. t)
    end
}

function DataChangeBus.printEventCounter()
    if DataChangeBus.debug then print("[#EventCounter] value " .. eventCounter) end
end

local function registerDefaultListeners()
    DataChangeBus.addListener(require("ce.hub.publish.InternalDataStore"))
    DataChangeBus.addListener(require("ce.hub.publish.ServerEventDispatcher"))
end

function DataChangeBus.initialize()
    if initialized then return end

    registerDefaultListeners()
    initialized = true
    DataChangeBus.fireCompleteReset()
end

local function fire(eventType, payload)
    if not initialized then DataChangeBus.initialize() end
    eventCounter = eventCounter + 1
    local event = { eventCounter = eventCounter, type = eventType, payload = payload }
    for listener in pairs(listeners) do listener.fireEvent(event) end
end

local function normalizeElementArgs(ceType, keyId, keyOrElement, element)
    assert(ceType, "expected ceType")
    assert(keyId, "expected keyId")

    if element == nil then
        assert(keyOrElement, "expected keyOrElement")
        assert(type(keyOrElement) == "table", "expected element as table")
        local normalizedElement = keyOrElement
        assert(normalizedElement[keyId], "the element must contain the key")
        return normalizedElement
    end

    local key = keyOrElement
    local normalizedElement = element
    assert(key ~= nil, "expected key")
    assert(normalizedElement, "expected element")
    assert(type(normalizedElement) == "table", "expected element as table")
    if normalizedElement[keyId] == nil then
        normalizedElement[keyId] = key
    else
        assert(normalizedElement[keyId] == key, "the key must match element[keyId]")
    end

    return normalizedElement
end

function DataChangeBus.fireDataChanged(ceType, keyId, keyOrElement, element)
    local normalizedElement = normalizeElementArgs(ceType, keyId, keyOrElement, element)
    fire(DataChangeBus.eventType.dataChanged, { ceType = ceType, keyId = keyId, element = normalizedElement })
end

function DataChangeBus.fireDataAdded(ceType, keyId, keyOrElement, element)
    local normalizedElement = normalizeElementArgs(ceType, keyId, keyOrElement, element)
    fire(DataChangeBus.eventType.dataAdded, { ceType = ceType, keyId = keyId, element = normalizedElement })
end

function DataChangeBus.fireDataRemoved(ceType, keyId, keyOrElement, element)
    local normalizedElement = normalizeElementArgs(ceType, keyId, keyOrElement, element)
    fire(DataChangeBus.eventType.dataRemoved, { ceType = ceType, keyId = keyId, element = normalizedElement })
end

function DataChangeBus.fireListChange(ceType, keyId, list)
    assert(ceType, "expected ceType")
    assert(keyId, "expected keyId")
    assert(list, "expected list")
    for _, v in pairs(list) do assert(v[keyId], "each element must contain the key") end
    fire(DataChangeBus.eventType.listChanged, { ceType = ceType, keyId = keyId, list = list })
end

function DataChangeBus.addListener(listener) listeners[listener] = true end

function DataChangeBus.fireCompleteReset()
    fire(DataChangeBus.eventType.completeReset, { info = "-- fire a data reset on first start --" })
end

if DataChangeBus.debug then DataChangeBus.addListener(DataChangeBus.printListener) end

return DataChangeBus
