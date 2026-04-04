insulate("ce.hub.data.switches.SwitchStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.switches.SwitchStatePublisher")
        clearModule("ce.hub.data.switches.SwitchDataCollector")
        clearModule("ce.hub.data.switches.SwitchDtoFactory")
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
        local SwitchStatePublisher = require("ce.hub.data.switches.SwitchStatePublisher")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SwitchStatePublisher.initialize()
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
