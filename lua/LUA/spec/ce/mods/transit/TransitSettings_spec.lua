insulate("ce.mods.transit.TransitSettings", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.util.StorageUtility")
        clearModule("ce.mods.transit.RoadStation")
        clearModule("ce.mods.transit.TransitSettings")
    end)

    after_each(function ()
        local StorageUtility = require("ce.hub.util.StorageUtility")
        StorageUtility.reset()
    end)

    it("loads the departure info setting from storage", function ()
        local TransitSettings = require("ce.mods.transit.TransitSettings")

        EEPSaveData(22, "depInfo=true,")
        TransitSettings.loadSettingsFromSlot(22)

        assert.is_true(TransitSettings.showDepartureTippText)
    end)

    it("saves the departure info setting", function ()
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local TransitSettings = require("ce.mods.transit.TransitSettings")

        TransitSettings.loadSettingsFromSlot(23)
        TransitSettings.setShowDepartureTippText(true)

        local data = StorageUtility.loadTable(23, "Transit settings")
        assert.equals("true", data["depInfo"])
    end)

    it("refreshes station displays after changing the setting", function ()
        local TransitSettings = require("ce.mods.transit.TransitSettings")
        local RoadStation = require("ce.mods.transit.RoadStation")
        local refreshCalls = 0

        local showTippTextStub = stub(RoadStation, "showTippText", function () refreshCalls = refreshCalls + 1 end)
        finally(function () showTippTextStub:revert() end)

        TransitSettings.loadSettingsFromSlot(24)
        TransitSettings.setShowDepartureTippText(true)

        assert.equals(1, refreshCalls)
    end)

    it("persists setting changes across a Lua reload", function ()
        local TransitSettings = require("ce.mods.transit.TransitSettings")

        TransitSettings.loadSettingsFromSlot(25)
        TransitSettings.setShowDepartureTippText(true)

        clearModule("ce.hub.util.StorageUtility")
        clearModule("ce.mods.transit.TransitSettings")
        TransitSettings = require("ce.mods.transit.TransitSettings")
        TransitSettings.loadSettingsFromSlot(25)

        assert.is_true(TransitSettings.showDepartureTippText)
    end)

    it("loads saved false values over previous true values", function ()
        local TransitSettings = require("ce.mods.transit.TransitSettings")

        EEPSaveData(26, "depInfo=false,")
        TransitSettings.showDepartureTippText = true
        TransitSettings.loadSettingsFromSlot(26)

        assert.is_false(TransitSettings.showDepartureTippText)
    end)
end)
