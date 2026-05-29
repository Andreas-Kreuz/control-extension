insulate("ce.hub.data.scenario.ScenarioUpdater", function ()
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
        clearModule("ce.hub.data.scenario.ScenarioUpdater")
        clearModule("ce.hub.data.scenario.ScenarioRegistry")
        clearModule("ce.hub.data.scenario.ScenarioDiscovery")

        rawset(_G, "EEPLng", "GER")
        rawset(_G, "EEPGetAnlVer", function () return 18.2 end)
        rawset(_G, "EEPGetAnlLng", function () return "ENG" end)
        rawset(_G, "EEPGetAnlName", function () return "Sample" end)
        rawset(_G, "EEPGetAnlPath", function () return "C:/Layouts/Sample.anl3" end)
        rawset(_G, "EEPGetTrainActive", function () return "#ICE" end)
        rawset(_G, "EEPRollingstockGetActive", function () return "BR 218" end)
        rawset(_G, "EEPGetTimeLapse", function () return 4 end)

        require("ce.hub.data.scenario.ScenarioDiscovery").initFromAnl3({
            cameras = {
                static = { "Bahnhof", "Leer", "Kreuzung" },
                dynamic = { "Fahrtwind" }
            }
        })
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

    it("updates scenario metadata and active selections", function ()
        local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
        local ScenarioUpdater = require("ce.hub.data.scenario.ScenarioUpdater")

        ScenarioUpdater.runUpdate()

        local scenario = ScenarioRegistry.get()
        assert.same({
                        id = "scenario",
                        name = "scenario",
                        scenarioName = "Sample",
                        scenarioPath = "C:/Layouts/Sample.anl3",
                        savedWithEep = 18.2,
                        scenarioLanguage = "ENG",
                        eepLanguage = "GER",
                        activeTrain = "#ICE",
                        activeRollingStock = "BR 218",
                        timeLapse = 4,
                        staticCameras = { "Bahnhof", "Kreuzung" },
                        dynamicCameras = { "Fahrtwind" },
                        dirtyFields = {},
                        needsFullSend = true
                    }, scenario)
    end)
end)