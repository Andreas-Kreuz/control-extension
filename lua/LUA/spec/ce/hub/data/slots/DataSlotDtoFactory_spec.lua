insulate("ce.hub.data.slots.DataSlotDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.slots.DataSlotDtoFactory")
    end)

    it("projects slots to detached DTO tables with ceType metadata", function ()
        local DataSlotDtoFactory = require("ce.hub.data.slots.DataSlotDtoFactory")
        local slot = { id = 4, name = "Slot 4", data = "abc" }

        local filledRoom, filledKeyId, filledKey, filledDto = DataSlotDtoFactory.createFilledDataSlotDto(slot)
        local listRoom, listKeyId, filledDtos = DataSlotDtoFactory.createFilledDataSlotDtoList({ slot })
        local emptyRoom, emptyKeyId, emptyKey, emptyDto = DataSlotDtoFactory.createEmptyDataSlotDto(slot)
        slot.data = "changed"

        assert.equals("ce.hub.SaveSlot", filledRoom)
        assert.equals("id", filledKeyId)
        assert.equals(4, filledKey)
        assert.same({ ceType = "ce.hub.SaveSlot", id = 4, name = "Slot 4", data = "abc" }, filledDto)
        assert.equals("ce.hub.SaveSlot", listRoom)
        assert.equals("id", listKeyId)
        assert.same({ { ceType = "ce.hub.SaveSlot", id = 4, name = "Slot 4", data = "abc" } }, filledDtos)
        assert.equals("ce.hub.FreeSlot", emptyRoom)
        assert.equals("id", emptyKeyId)
        assert.equals(4, emptyKey)
        assert.same({ ceType = "ce.hub.FreeSlot", id = 4, name = "Slot 4", data = "abc" }, emptyDto)
    end)
end)
