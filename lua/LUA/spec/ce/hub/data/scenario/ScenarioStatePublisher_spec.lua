insulate("ce.hub.data.scenario.ScenarioStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPLng = _G.EEPLng
    local originalEEPGetAnlVer = _G.EEPGetAnlVer
    local originalEEPGetAnlLng = _G.EEPGetAnlLng
    local originalEEPGetAnlName = _G.EEPGetAnlName
    local originalEEPGetAnlPath = _G.EEPGetAnlPath
    local originalEEPGetTrainActive = _G.EEPGetTrainActive
    local originalEEPRollingstockGetActive = _G.EEPRollingstockGetActive
    local originalEEPGetTimeLapse = _G.EEPGetTimeLapse

    before_each(function ()
        clearModule("ce.hub.data.scenario.ScenarioStatePublisher")
        clearModule("ce.hub.data.scenario.ScenarioDtoFactory")
        clearModule("ce.hub.data.scenario.ScenarioRegistry")
        clearModule("ce.hub.data.scenario.ScenarioUpdater")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        rawset(_G, "EEPLng", "GER")
        rawset(_G, "EEPGetAnlVer", function () return 18.2 end)
        rawset(_G, "EEPGetAnlLng", function () return "ENG" end)
        rawset(_G, "EEPGetAnlName", function () return "Sample" end)
        rawset(_G, "EEPGetAnlPath", function () return "C:/Layouts/Sample.anl3" end)
        rawset(_G, "EEPGetTrainActive", function () return "#ICE" end)
        rawset(_G, "EEPRollingstockGetActive", function () return "BR 218" end)
        rawset(_G, "EEPGetTimeLapse", function () return 4 end)
    end)

    after_each(function ()
        rawset(_G, "EEPLng", originalEEPLng)
        rawset(_G, "EEPGetAnlVer", originalEEPGetAnlVer)
        rawset(_G, "EEPGetAnlLng", originalEEPGetAnlLng)
        rawset(_G, "EEPGetAnlName", originalEEPGetAnlName)
        rawset(_G, "EEPGetAnlPath", originalEEPGetAnlPath)
        rawset(_G, "EEPGetTrainActive", originalEEPGetTrainActive)
        rawset(_G, "EEPRollingstockGetActive", originalEEPRollingstockGetActive)
        rawset(_G, "EEPGetTimeLapse", originalEEPGetTimeLapse)
    end)

    it("fires scenario ceTypes with the singleton wire format", function ()
        local ScenarioStatePublisher = require("ce.hub.data.scenario.ScenarioStatePublisher")
        local ScenarioUpdater = require("ce.hub.data.scenario.ScenarioUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        ScenarioUpdater.runUpdate()
        ScenarioStatePublisher.syncState()

        assert.same({
                        scenario = {
                            ceType = "ce.hub.Scenario",
                            id = "scenario",
                            name = "scenario",
                            scenarioName = "Sample",
                            scenarioPath = "C:/Layouts/Sample.anl3",
                            savedWithEep = 18.2,
                            scenarioLanguage = "ENG",
                            eepLanguage = "GER",
                            activeTrain = "#ICE",
                            activeRollingStock = "BR 218",
                            timeLapse = 4
                        }
                    }, DataStore.getCeType("ce.hub.Scenario"))
    end)
end)
