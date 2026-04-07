insulate("ce.hub.data.switches.SwitchStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.switches.SwitchStatePublisher")
        clearModule("ce.hub.data.switches.SwitchDiscovery")
        clearModule("ce.hub.data.switches.SwitchDtoFactory")
        clearModule("ce.hub.data.switches.SwitchRegistry")
        clearModule("ce.hub.data.switches.SwitchUpdater")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        local states = {
            [8] = {
                position = 2,
                tag = "South"
            }
        }

        stub(_G, "EEPGetSwitch", function (id)
            local entry = states[id]
            if not entry then return 0 end
            return entry.position
        end)
        stub(_G, "EEPSwitchGetTagText", function (id)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.tag
        end)
    end)

    after_each(function ()
        _G.EEPGetSwitch:revert()
        _G.EEPSwitchGetTagText:revert()
    end)

    it("fires switch ceTypes with the existing wire format", function ()
        local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
        local SwitchStatePublisher = require("ce.hub.data.switches.SwitchStatePublisher")
        local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SwitchDiscovery.runInitialDiscovery()
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
end)
