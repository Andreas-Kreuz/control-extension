-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/data-slots/DataSlotLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotDtoFactory ...") end

local TableUtils = require("ce.hub.util.TableUtils")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local DataSlotDtoFactory = {}

local KEY_ID = "id"
local FILLED_CE_TYPE = HubCeTypes.SaveSlot
local EMPTY_CE_TYPE = HubCeTypes.FreeSlot

local function toDataSlotDto(ceType, slot)
    return {
        ceType = ceType,
        id = slot.id,
        name = slot.name,
        data = slot.data
    }
end

local function createDataSlotDtoList(ceType, slots)
    local dataSlotDtos = {}
    for _, slot in pairs(slots) do table.insert(dataSlotDtos, toDataSlotDto(ceType, slot)) end
    return ceType, KEY_ID, dataSlotDtos
end

function DataSlotDtoFactory.createFilledDataSlotDto(slot)
    local dto = toDataSlotDto(FILLED_CE_TYPE, slot)
    return FILLED_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function DataSlotDtoFactory.createFilledDataSlotDtoList(filledSlots)
    return createDataSlotDtoList(FILLED_CE_TYPE, TableUtils.valuesOfDict(filledSlots))
end

function DataSlotDtoFactory.createEmptyDataSlotDto(slot)
    local dto = toDataSlotDto(EMPTY_CE_TYPE, slot)
    return EMPTY_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function DataSlotDtoFactory.createEmptyDataSlotDtoList(emptySlots)
    return createDataSlotDtoList(EMPTY_CE_TYPE, TableUtils.valuesOfDict(emptySlots))
end

return DataSlotDtoFactory
