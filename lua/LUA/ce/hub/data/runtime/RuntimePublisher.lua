if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local RuntimeDtoFactory = require("ce.hub.data.runtime.RuntimeDtoFactory")
local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")

local RuntimePublisher = {}

function RuntimePublisher.syncState()
    local runtimeEntries = RuntimeRegistry.get()
    if not runtimeEntries then return {} end
    DataChangeBus.fireListChange(RuntimeDtoFactory.createRuntimeDtoList(runtimeEntries))
    return {}
end

return RuntimePublisher
