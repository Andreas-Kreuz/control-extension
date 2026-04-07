insulate("ce.hub.data.switches.SwitchDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.switches.SwitchDataCollector")

        local states = {
            [4] = {
                position = 2,
                tag = "West"
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

    it("collects initial switches by id and refreshes their fields", function ()
        local SwitchDataCollector = require("ce.hub.data.switches.SwitchDataCollector")

        local switches = SwitchDataCollector.collectInitialSwitches()
        SwitchDataCollector.refreshSwitches(switches)

        assert.same(1, #switches)
        assert.same({
                        id = 4,
                        position = 2,
                        tag = "West"
                    }, switches[1])
    end)
end)
