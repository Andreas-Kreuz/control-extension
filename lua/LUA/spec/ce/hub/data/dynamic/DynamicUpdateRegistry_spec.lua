insulate("ce.hub.data.DynamicUpdateRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.DynamicUpdateRegistry")
    end)

    it("tracks selected ids and their initial-send state", function ()
        local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")

        DynamicUpdateRegistry.startUpdatesFor("ce.hub.Train", "T1")

        assert.is_true(DynamicUpdateRegistry.isSelected("ce.hub.Train", "T1"))
        assert.is_true(DynamicUpdateRegistry.needsInitialSend("ce.hub.Train", "T1"))

        DynamicUpdateRegistry.markSent("ce.hub.Train", "T1")
        assert.is_false(DynamicUpdateRegistry.needsInitialSend("ce.hub.Train", "T1"))

        DynamicUpdateRegistry.stopUpdatesFor("ce.hub.Train", "T1")
        assert.is_false(DynamicUpdateRegistry.isSelected("ce.hub.Train", "T1"))
    end)
end)
