insulate("ce.hub.data.scenario.ScenarioDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local TEMP_FILE = "spec/ce/hub/data/scenario/_scenario_anl3_test_tmp.xml"

    local function writeTempXml(content)
        local f = assert(io.open(TEMP_FILE, "w"))
        f:write(content)
        f:close()
        return TEMP_FILE
    end

    local function discoverScenario(xml)
        _G.EEPLoadData = _G.EEPLoadData or function () return false, nil end

        clearModule("ce.hub.data.scenario.ScenarioDiscovery")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Parser")

        local EepScenarioAnl3Parser = require("ce.hub.eep.scenario.EepScenarioAnl3Parser")
        local EepScenarioAnl3Discovery = require("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        local ScenarioDiscovery = require("ce.hub.data.scenario.ScenarioDiscovery")

        local root = assert(EepScenarioAnl3Parser.loadAnlage(writeTempXml(xml)))
        EepScenarioAnl3Discovery.fillDiscoveries(root)
        return ScenarioDiscovery
    end

    after_each(function ()
        os.remove(TEMP_FILE)
    end)

    it("discovers static and dynamic cameras from anl3", function ()
        local ScenarioDiscovery = discoverScenario(table.concat({
                                                                    '<?xml version="1.0" encoding="UTF-8"?>',
                                                                    "<sutrackp>",
                                                                    '<Kammerasammlung cnt="3">',
                                                                    '<Kammera name="Bahnhof" Dynamic="0"/>',
                                                                    '<Kammera name="Fahrtwind" Dynamic="1"/>',
                                                                    '<Kammera name="Leer" Dynamic="0"/>',
                                                                    "</Kammerasammlung>",
                                                                    "</sutrackp>"
                                                                }, ""))

        assert.same({ "Bahnhof" }, ScenarioDiscovery.getStaticCameras())
        assert.same({ "Fahrtwind" }, ScenarioDiscovery.getDynamicCameras())
    end)
end)
