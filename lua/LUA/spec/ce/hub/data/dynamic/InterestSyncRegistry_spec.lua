insulate("ce.hub.data.InterestSyncRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.InterestSyncRegistry")
    end)

    it("tracks selected ids and their initial-send state", function ()
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncFor("ce.hub.Train", "T1")

        assert.is_true(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
        assert.is_true(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))

        InterestSyncRegistry.markSent("ce.hub.Train", "T1")
        assert.is_false(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))

        InterestSyncRegistry.stopSyncFor("ce.hub.Train", "T1")
        assert.is_false(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
    end)
end)
