-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/data-slots/DataSlotLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TableUtils = require("ce.hub.util.TableUtils")

---@class DataSlotDtoFactory
---@field createFullDto fun(ceType: string, slot: table):string,string,string|number,DataSlotDto
---@field createPatchDto fun(ceType: string, slot: table, dirtyFields: table<string, boolean>):string,string,
---string|number,DataSlotDto
---@field createRemovalDto fun(ceType: string, slotId: number|string):string,string,string|number,table
---@field createFilledDataSlotDtoList fun(filledSlots: table):string,string,table
---@field createEmptyDataSlotDtoList fun(emptySlots: table):string,string,table
local DataSlotDtoFactory = {}

local FILLED_CE_TYPE = HubCeTypes.SaveSlot
local EMPTY_CE_TYPE = HubCeTypes.FreeSlot
local KEY_ID = "id"

-- DtoFields: class definition in DataSlotDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (slot) return slot.name end,
        placeholder = ""
    },
    data = {
        getValue = function (slot) return slot.data end,
        placeholder = ""
    },
}

local function buildDataSlotDto(ceType, slot)
    return DtoBuilder.buildFullDto({
        ceType = ceType,
        id = slot.id
    }, slot, dtoFields)
end

local function buildDataSlotPatchDto(ceType, slot, dirtyFields)
    return DtoBuilder.buildPatchDto({
        ceType = ceType,
        id = slot.id
    }, slot, dirtyFields, dtoFields)
end

function DataSlotDtoFactory.createFullDto(ceType, slot)
    local dto = buildDataSlotDto(ceType, slot)
    return ceType, KEY_ID, dto[KEY_ID], dto
end

function DataSlotDtoFactory.createPatchDto(ceType, slot, dirtyFields)
    local dto = buildDataSlotPatchDto(ceType, slot, dirtyFields)
    return ceType, KEY_ID, dto[KEY_ID], dto
end

function DataSlotDtoFactory.createRemovalDto(ceType, slotId)
    return ceType, KEY_ID, slotId, { ceType = ceType, id = slotId }
end

function DataSlotDtoFactory.filledCeType()
    return FILLED_CE_TYPE
end

function DataSlotDtoFactory.emptyCeType()
    return EMPTY_CE_TYPE
end

local function createDataSlotDtoList(ceType, slots)
    local dataSlotDtos = {}
    for _, slot in pairs(slots) do table.insert(dataSlotDtos, buildDataSlotDto(ceType, slot)) end
    return ceType, KEY_ID, dataSlotDtos
end

function DataSlotDtoFactory.createFilledDataSlotDtoList(filledSlots)
    return createDataSlotDtoList(FILLED_CE_TYPE, TableUtils.valuesOfDict(filledSlots))
end

function DataSlotDtoFactory.createEmptyDataSlotDtoList(emptySlots)
    return createDataSlotDtoList(EMPTY_CE_TYPE, TableUtils.valuesOfDict(emptySlots))
end

return DataSlotDtoFactory
