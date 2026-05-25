insulate("ce.hub.eep.scenario.EepScenarioDataController", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originalEEPGetAnlName
    local originalEEPShowInfoTextTop
    local printStub
    local loadedPaths
    local fillCalls
    local options
    local processPendingCalls
    local refreshedXmlModels
    local parserLuaPath
    local parserCoverage
    local shownInfoTexts

    local function loadController()
        clearModule("ce.hub.eep.scenario.EepScenarioDataController")
        package.loaded["ce.hub.eep.scenario.EepScenarioAnl3Parser"] = {
            loadAnlage = function (path)
                loadedPaths[#loadedPaths + 1] = path
                return { path = path }
            end
        }
        package.loaded["ce.hub.eep.scenario.EepScenarioAnl3Discovery"] = {
            getLuaPath = function () return parserLuaPath end,
            fillDiscoveries = function ()
                fillCalls = fillCalls + 1
                return parserCoverage
            end
        }
        package.loaded["ce.hub.options.HubOptionsRegistry"] = {
            getAllOptions = function () return options end
        }
        package.loaded["ce.hub.data.rollingstock.RollingStockModelInfoRegistry"] = {
            processPending = function (batchSize)
                processPendingCalls[#processPendingCalls + 1] = batchSize
                return { "ModelA.3dm" }
            end
        }
        package.loaded["ce.hub.data.rollingstock.RollingStockRegistry"] = {
            refreshModelInfoForXmlModels = function (xmlModels)
                refreshedXmlModels[#refreshedXmlModels + 1] = xmlModels
            end
        }
        return require("ce.hub.eep.scenario.EepScenarioDataController")
    end

    before_each(function ()
        originalEEPGetAnlName = _G.EEPGetAnlName
        originalEEPShowInfoTextTop = _G.EEPShowInfoTextTop
        printStub = stub(_G, "print")
        loadedPaths = {}
        fillCalls = 0
        options = {}
        processPendingCalls = {}
        refreshedXmlModels = {}
        shownInfoTexts = {}
        parserLuaPath = "\\Scenario.lua"
        parserCoverage = { signals = true, tracks = true }
        rawset(_G, "EEPGetAnlName", function () return "Scenario" end)
        rawset(_G, "EEPShowInfoTextTop", function (_, _, _, _, _, _, text)
            shownInfoTexts[#shownInfoTexts + 1] = text
        end)
    end)

    after_each(function ()
        printStub:revert()
        rawset(_G, "EEPGetAnlName", originalEEPGetAnlName)
        rawset(_G, "EEPShowInfoTextTop", originalEEPShowInfoTextTop)
        clearModule("ce.hub.eep.scenario.EepScenarioDataController")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Parser")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        clearModule("ce.hub.options.HubOptionsRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
    end)

    it("loads the configured anl3 path on init and returns coverage", function ()
        local Controller = loadController()
        Controller.update({ anl3Path = "C:\\EEP\\Anlagen\\Scenario.anl3" })

        local result = Controller.init()

        assert.is_true(result.success)
        assert.same({ "C:\\EEP\\Anlagen\\Scenario.anl3" }, loadedPaths)
        assert.same(parserCoverage, result.coverage)
        assert.equals(1, fillCalls)
        assert.matches("CE%-Hub: Anlage Scenario%.anl3 geladen in %d+%.%d%d Sekunden", shownInfoTexts[1])
    end)

    it("skips discoveries when the anl3 Lua path does not match EEPGetAnlName", function ()
        rawset(_G, "EEPGetAnlName", function () return "OtherScenario" end)
        local Controller = loadController()
        Controller.update({ anl3Path = "Scenario.anl3" })

        local result = Controller.init()

        assert.is_false(result.success)
        assert.equals("mismatch", result.error)
        assert.equals(0, fillCalls)
    end)

    it("reloads the saved anl3 after the delay and warns when the path changed", function ()
        local Controller = loadController()
        Controller.update({ anl3Path = "Original.anl3" })
        Controller.init()

        Controller.update({ savedAnl3Path = "Saved.anl3" })
        Controller.update()
        Controller.update()
        Controller.update()
        assert.same({ "Original.anl3" }, loadedPaths)

        Controller.update()
        assert.same({ "Original.anl3", "Saved.anl3" }, loadedPaths)
        assert.stub(printStub).was_called_with(
            "[CeHubModule] Saved anl3 path differs from ControlExtension option. Please update " ..
            "ControlExtension.setOptions({ anl3path = \"Saved.anl3\" })."
        )
    end)

    it("starts rolling stock resource parsing on the second update with the default batch size", function ()
        local Controller = loadController()
        Controller.init()

        Controller.update()
        assert.same({}, processPendingCalls)

        Controller.update()
        assert.same({ 20 }, processPendingCalls)
        assert.same({ { "ModelA.3dm" } }, refreshedXmlModels)
    end)

    it("uses the configured rolling stock resource batch size", function ()
        options = {
            eepResources = {
                rollingStockModelInfoBatchSize = 7
            }
        }
        local Controller = loadController()
        Controller.init()

        Controller.update()
        Controller.update()

        assert.same({ 7 }, processPendingCalls)
    end)
end)
