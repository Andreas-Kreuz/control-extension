if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStatePublisher ...") end
local StructurePublisher = require("ce.hub.data.structures.StructurePublisher")
StructureStatePublisher = {}
StructureStatePublisher.enabled = true
local initialized = false
StructureStatePublisher.name = "ce.hub.data.structures.StructureStatePublisher"

function StructureStatePublisher.initialize()
    if not StructureStatePublisher.enabled or initialized then return end
    initialized = true
end

function StructureStatePublisher.syncState()
    if not StructureStatePublisher.enabled then return end

    if not initialized then StructureStatePublisher.initialize() end

    return StructurePublisher.syncState()
end

return StructureStatePublisher
