insulate("ce.hub.data.switches.SwitchStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local eepGetSwitchStub
    local eepSwitchGetTagTextStub

    before_each(function ()
        clearModule("ce.hub.data.switches.SwitchStatePublisher")
        clearModule("ce.hub.data.switches.SwitchDiscovery")
        clearModule("ce.hub.data.switches.SwitchDtoFactory")
        clearModule("ce.hub.data.switches.SwitchRegistry")
        clearModule("ce.hub.data.switches.SwitchUpdater")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.data.HubCeTypes")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        local states = {
            [8] = {
                position = 2,
                tag = "South"
            }
        }

        eepGetSwitchStub = stub(_G, "EEPGetSwitch", function (id)
            local entry = states[id]
            if not entry then return 0 end
            return entry.position
        end)
        eepSwitchGetTagTextStub = stub(_G, "EEPSwitchGetTagText", function (id)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.tag
        end)
    end)

    after_each(function ()
        eepGetSwitchStub:revert()
        eepSwitchGetTagTextStub:revert()
        local InterestSyncRegistry = package.loaded["ce.hub.data.InterestSyncRegistry"]
        if InterestSyncRegistry then InterestSyncRegistry.clearAll() end
    end)

    it("fires switch ceTypes with the existing wire format", function ()
        local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
        local SwitchStatePublisher = require("ce.hub.data.switches.SwitchStatePublisher")
        local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SwitchDiscovery.runInitialDiscovery()
        InterestSyncRegistry.startSyncFor(HubCeTypes.Switch, "8")
        SwitchUpdater.runUpdate()
        SwitchStatePublisher.syncState()

        assert.same({
                        ["8"] = {
                            ceType = "ce.hub.Switch",
                            id = 8,
                            position = 2,
                            tag = "South"
                        }
                    }, DataStore.getCeType("ce.hub.Switch"))
    end)

    it("does not pull switch tags without interest", function ()
        local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
        local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
        local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

        SwitchDiscovery.runInitialDiscovery()
        eepSwitchGetTagTextStub:clear()

        SwitchUpdater.runUpdate()

        assert.stub(eepSwitchGetTagTextStub).was_not_called()
        assert.same("", SwitchRegistry.get(8):peekTag())
    end)

    it("does not pull switch positions without interest", function ()
        local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
        local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
        local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

        SwitchDiscovery.runInitialDiscovery()
        eepGetSwitchStub:clear()

        SwitchUpdater.runUpdate()

        assert.stub(eepGetSwitchStub).was_not_called()
        assert.same(0, SwitchRegistry.get(8):peekPosition())
    end)
end)
