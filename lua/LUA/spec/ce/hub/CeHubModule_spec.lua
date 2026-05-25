insulate("CeHubModule", function ()
    local function clearModule(name)
        package.loaded[name] = nil
    end
    local printStub
    local ioInitInitializeStub
    local originalEEPGetAnlName
    local originalEEPOnSaveAnl
    local TEMP_ANL3 = "spec/ce/hub/_cehub_anl3_tmp.xml"
    local TEMP_SAVED_ANL3 = "spec/ce/hub/_cehub_anl3_saved_tmp.xml"

    local function writeTempAnl3(path, luaName, signalId)
        local xml = table.concat({
                                     '<?xml version="1.0" encoding="UTF-8"?>',
                                     "<sutrackp>",
                                     '<Gleissystem GleissystemID="3" TrackSystemNumber="3">',
                                     '<Gleis GleisID="1"><Meldung name="S" Key_Id="' ..
                                     tostring(signalId) .. '"/></Gleis>',
                                     "</Gleissystem>",
                                     "<Gebaeudesammlung/>",
                                     '<Fuhrpark FuhrparkID="1">',
                                     '<Zugverband name="#Train A"><Gleisort gleissystemID="3" gleisID="1"/>',
                                     '<Rollmaterial name="RS A" typ="STRASSE\\BUS\\A.3dm"/></Zugverband>',
                                     "</Fuhrpark>",
                                     '<EEPLua LUAPath="\\' .. luaName .. '.lua"/>',
                                     "</sutrackp>"
                                 }, "")
        local file = assert(io.open(path, "w"))
        file:write(xml)
        file:close()
        return path
    end

    before_each(function ()
        originalEEPGetAnlName = _G.EEPGetAnlName
        originalEEPOnSaveAnl = _G.EEPOnSaveAnl
        printStub = stub(_G, "print")
        clearModule("ce.ControlExtension")
        clearModule("ce.hub.ControlExtensionHub")
        clearModule("ce.hub.ModuleRegistry")
        clearModule("ce.hub.MainLoopRunner")
        clearModule("ce.hub.StatePublisherRegistry")
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.CeHubModule")
        clearModule("ce.hub.data.runtime.RuntimeMetrics")
        clearModule("ce.hub.util.TimedExecution")
        clearModule("ce.hub.eep.EepCallAnalyzer")
        clearModule("ce.hub.data.tracks.TracksStatePublisher")
        clearModule("ce.hub.data.tracks.Track")
        clearModule("ce.hub.data.tracks.TrackRegistry")
        clearModule("ce.hub.data.trains.TrainStatePublisher")
        clearModule("ce.hub.data.trains.TrainDiscovery")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainDiscoveryCache")
        clearModule("ce.hub.data.trains.TrainUpdater")
        clearModule("ce.hub.data.rollingstock.RollingStockStatePublisher")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockUpdater")
        clearModule("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        clearModule("ce.hub.eep.resources.RollingStockResourceParser")
        clearModule("ce.hub.data.trains.TrainDetection")
        clearModule("ce.hub.data.signals.SignalDiscovery")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.signals.SignalUpdater")
        clearModule("ce.hub.data.switches.SwitchDiscovery")
        clearModule("ce.hub.data.switches.SwitchRegistry")
        clearModule("ce.hub.data.switches.SwitchUpdater")
        clearModule("ce.hub.data.structures.StructureDiscovery")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.hub.data.structures.StructureUpdater")
        clearModule("ce.hub.data.contacts.ContactDiscovery")
        clearModule("ce.hub.data.routes.RouteDiscovery")
        clearModule("ce.hub.data.scenario.ScenarioDiscovery")
        clearModule("ce.hub.eep.scenario.EepScenarioDataController")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Parser")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.databridge.IoInit")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")
        ioInitInitializeStub = stub(require("ce.databridge.IoInit"), "initialize", function () end)
    end)

    after_each(function ()
        printStub:revert()
        ioInitInitializeStub:revert()
        local EepCallAnalyzer = package.loaded["ce.hub.eep.EepCallAnalyzer"]
        if EepCallAnalyzer then EepCallAnalyzer.reset() end
        rawset(_G, "EEPGetAnlName", originalEEPGetAnlName)
        rawset(_G, "EEPOnSaveAnl", originalEEPOnSaveAnl)
        os.remove(TEMP_ANL3)
        os.remove(TEMP_SAVED_ANL3)
    end)

    it("returns CeHubModule from setOptions and applies hub options", function ()
        local CeHubModule = require("ce.hub.CeHubModule")
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")

        ServerExchangeCoordinator.checkServerStatus = true

        assert.equals(CeHubModule, CeHubModule.setOptions({
            waitForServer = false,
            ceTypes = {
                time = { publish = false }
            }
        }))

        CeHubModule.init()

        local publisherNames = {}
        for _, statePublisher in ipairs(StatePublisherRegistry.getStatePublishers()) do
            publisherNames[statePublisher.name] = true
        end

        assert.is_false(ServerExchangeCoordinator.checkServerStatus)
        assert.is_true(publisherNames["ce.hub.data.tracks.TracksStatePublisher"])
        assert.is_true(publisherNames["ce.hub.data.trains.TrainStatePublisher"])
        assert.is_true(publisherNames["ce.hub.data.rollingstock.RollingStockStatePublisher"])
        assert.is_nil(publisherNames["ce.hub.data.time.TimeStatePublisher"])
    end)

    it("works with inline hub configuration during module registration", function ()
        local ControlExtension = require("ce.ControlExtension")
        local CeHubModule = require("ce.hub.CeHubModule")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")

        ControlExtension.addModules(
            require("ce.mods.road.CeRoadModule"),
            CeHubModule.setOptions({
                ceTypes = {
                    time = { publish = false }
                }
            })
        )

        ControlExtension.runTasks(1)

        local publisherNames = {}
        for _, statePublisher in ipairs(StatePublisherRegistry.getStatePublishers()) do
            publisherNames[statePublisher.name] = true
        end

        assert.is_true(publisherNames["ce.hub.data.tracks.TracksStatePublisher"])
        assert.is_true(publisherNames["ce.hub.data.trains.TrainStatePublisher"])
        assert.is_true(publisherNames["ce.hub.data.rollingstock.RollingStockStatePublisher"])
        assert.is_true(publisherNames["ce.mods.road.data.RoadStatePublisher"])
        assert.is_nil(publisherNames["ce.hub.data.time.TimeStatePublisher"])
    end)

    it("records timings for initial discovery and recurring updates", function ()
        local CeHubModule = require("ce.hub.CeHubModule")
        local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")

        CeHubModule.init()
        CeHubModule.run()

        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Module").count)
        assert.equals(1, RuntimeMetrics.get("Discovery-init/ce.hub.Signal").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Scenario").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Structure").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Time").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.RollingStock").count)
        assert.equals(1, RuntimeMetrics.get("Discovery-init/ce.hub.Train").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Module").count)
        assert.equals(1, RuntimeMetrics.get("Discovery/ce.hub.Signal").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Scenario").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Structure").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Time").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.RollingStock").count)
        assert.equals(1, RuntimeMetrics.get("Discovery/ce.hub.Train").count)
        assert.is_true(RuntimeMetrics.get("Discovery/ce.hub.Train").lastTime >= 0)
    end)

    it("marks EEP calls inside hub discovery phases separately #eepAnalyzer", function ()
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")

        EepCallAnalyzer.configure({ enabled = true, runs = 2 })
        local CeHubModule = require("ce.hub.CeHubModule")
        EepCallAnalyzer.beginRun()

        CeHubModule.init()

        local result = EepCallAnalyzer.getResult()
        assert.is_true(result.totals.calls > 0)
        assert.is_true(result.totals.discoveryCalls > 0)
        assert.is_true(result.totals.discoveryCalls <= result.totals.calls)
    end)

    it("skips expensive initial discovery scans when anl3 discovery succeeds", function ()
        rawset(_G, "EEPGetAnlName", function () return "Anl3Skip" end)
        writeTempAnl3(TEMP_ANL3, "Anl3Skip", 5)

        local CeHubModule = require("ce.hub.CeHubModule")
        local RollingStockResourceParser = require("ce.hub.eep.resources.RollingStockResourceParser")
        local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")
        local resourceParseCalls = 0
        local infoForXmlModelStub = stub(RollingStockResourceParser, "infoForXmlModel", function ()
            resourceParseCalls = resourceParseCalls + 1
            return {}
        end)
        finally(function () infoForXmlModelStub:revert() end)

        CeHubModule.setAnl3Path(TEMP_ANL3)
        CeHubModule.init()

        assert.equals(0, resourceParseCalls)
        assert.equals(0, RuntimeMetrics.get("Discovery-init/ce.hub.Signal").count)
        assert.equals(0, RuntimeMetrics.get("Discovery-init/ce.hub.Switch").count)
        assert.equals(0, RuntimeMetrics.get("Discovery-init/ce.hub.Structure").count)
        assert.equals(1, RuntimeMetrics.get("Discovery-init/ce.hub.Train").count)
        assert.is_true(SignalRegistry.has(5))
        assert.is_not_nil(TrackRegistry.get("road", 1))
    end)

    it("reloads anl3 after EEPOnSaveAnl and warns when the option path differs", function ()
        rawset(_G, "EEPGetAnlName", function () return "Anl3Reload" end)
        writeTempAnl3(TEMP_ANL3, "Anl3Reload", 5)
        writeTempAnl3(TEMP_SAVED_ANL3, "Anl3Reload", 9)

        local CeHubModule = require("ce.hub.CeHubModule")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        CeHubModule.setAnl3Path(TEMP_ANL3)
        CeHubModule.init()
        assert.is_true(SignalRegistry.has(5))

        _G.EEPOnSaveAnl(TEMP_SAVED_ANL3)
        CeHubModule.run()
        CeHubModule.run()
        CeHubModule.run()
        CeHubModule.run()

        assert.is_false(SignalRegistry.has(5))
        assert.is_true(SignalRegistry.has(9))
        assert.stub(printStub).was_called_with(
            "[CeHubModule] Saved anl3 path differs from ControlExtension option. Please update " ..
            "ControlExtension.setOptions({ anl3path = \"" .. TEMP_SAVED_ANL3 .. "\" })."
        )
    end)
end)
