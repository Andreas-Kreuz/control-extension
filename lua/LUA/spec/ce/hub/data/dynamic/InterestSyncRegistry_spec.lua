insulate("ce.hub.data.InterestSyncRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.InterestSyncRegistry")
    end)

    it("tracks selected ids and their initial-send state", function ()
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncFor("ce.hub.Train", "T1")

        assert.is_true(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
        assert.same({ T1 = true }, InterestSyncRegistry.getSelectedKeys("ce.hub.Train"))
        assert.is_true(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))

        InterestSyncRegistry.markSent("ce.hub.Train", "T1")
        assert.is_false(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))

        InterestSyncRegistry.stopSyncFor("ce.hub.Train", "T1")
        assert.is_false(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
    end)

    it("keeps manual and source-owned interest independent", function ()
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncFor("ce.hub.Train", "T1")
        InterestSyncRegistry.startSyncForSource("ce.hub.Train", "T1", "depot:1")
        InterestSyncRegistry.startSyncForSource("ce.hub.Train", "T2", "depot:2")

        assert.same({ T1 = true, T2 = true }, InterestSyncRegistry.getSelectedKeys("ce.hub.Train"))
        assert.is_true(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
        assert.is_true(InterestSyncRegistry.isSelected("ce.hub.Train", "T2"))

        InterestSyncRegistry.stopSyncForSource("ce.hub.Train", "T1", "depot:1")
        InterestSyncRegistry.stopSyncForSource("ce.hub.Train", "T2", "depot:2")

        assert.is_true(InterestSyncRegistry.isSelected("ce.hub.Train", "T1"))
        assert.is_false(InterestSyncRegistry.isSelected("ce.hub.Train", "T2"))
        assert.same({ T1 = true }, InterestSyncRegistry.getSelectedKeys("ce.hub.Train"))
    end)

    it("does not re-arm initial sends for unchanged manual interest", function ()
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncFor("ce.hub.Train", "T1")
        InterestSyncRegistry.markSent("ce.hub.Train", "T1")
        InterestSyncRegistry.startSyncFor("ce.hub.Train", "T1")

        assert.is_false(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))
    end)

    it("does not re-arm initial sends for unchanged source interest", function ()
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncForSource("ce.hub.Train", "T1", "depot:1")
        InterestSyncRegistry.markSent("ce.hub.Train", "T1")
        InterestSyncRegistry.startSyncForSource("ce.hub.Train", "T1", "depot:1")

        assert.is_false(InterestSyncRegistry.needsInitialSend("ce.hub.Train", "T1"))
    end)
end)
