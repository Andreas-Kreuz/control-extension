if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStatePublisher ...") end
local StructurePublisher = require("ce.hub.data.structures.StructurePublisher")
StructureStatePublisher = {}
StructureStatePublisher.enabled = true
local initialized = false
StructureStatePublisher.name = "ce.hub.data.structures.StructureStatePublisher"

StructureStatePublisher.options = {
    ceTypes = {
        structures = { ceType = "ce.hub.Structure", mode = "all" }
    },
    fields = {
        light = { collect = true },
        smoke = { collect = true },
        fire = { collect = true },
        tag = { collect = true }
    }
}

function StructureStatePublisher.initialize()
    if not StructureStatePublisher.enabled or initialized then return end
    initialized = true
end

function StructureStatePublisher.syncState()
    if not StructureStatePublisher.enabled then return end

    if not initialized then StructureStatePublisher.initialize() end

    return StructurePublisher.syncState(StructureStatePublisher.options)
end

return StructureStatePublisher
