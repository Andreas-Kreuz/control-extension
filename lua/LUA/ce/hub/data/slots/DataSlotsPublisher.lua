if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DataSlotDtoFactory = require("ce.hub.data.slots.DataSlotDtoFactory")
local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")

local DataSlotsPublisher = {}

function DataSlotsPublisher.syncState()
    DataChangeBus.fireListChange(DataSlotDtoFactory.createFilledDataSlotDtoList(DataSlotsRegistry.getFilled()))
    DataChangeBus.fireListChange(DataSlotDtoFactory.createEmptyDataSlotDtoList(DataSlotsRegistry.getEmpty()))
    return {}
end

return DataSlotsPublisher
