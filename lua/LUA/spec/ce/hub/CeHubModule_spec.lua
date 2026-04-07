insulate("CeHubModule", function ()
    local function clearModule(name)
        package.loaded[name] = nil
    end

    before_each(function ()
        stub(_G, "print")
        clearModule("ce.ControlExtension")
        clearModule("ce.hub.ControlExtensionHub")
        clearModule("ce.hub.ModuleRegistry")
        clearModule("ce.hub.MainLoopRunner")
        clearModule("ce.hub.StatePublisherRegistry")
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.CeHubModule")
        clearModule("ce.hub.data.runtime.RuntimeMetrics")
        clearModule("ce.hub.util.RuntimeRegistry")
        clearModule("ce.hub.data.tracks.TracksStatePublisher")
        clearModule("ce.hub.data.trains.TrainStatePublisher")
        clearModule("ce.hub.data.rollingstock.RollingStockStatePublisher")
        clearModule("ce.hub.data.trains.TrainDetection")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.databridge.IoInit")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")
        require("ce.databridge.IoInit").initialize = function () end
    end)

    after_each(function ()
        _G.print:revert()
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
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Structure").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.Time").count)
        assert.equals(1, RuntimeMetrics.get("Update-init/ce.hub.RollingStock").count)
        assert.equals(1, RuntimeMetrics.get("Discovery-init/ce.hub.Train").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Module").count)
        assert.equals(1, RuntimeMetrics.get("Discovery/ce.hub.Signal").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Structure").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.Time").count)
        assert.equals(1, RuntimeMetrics.get("Update/ce.hub.RollingStock").count)
        assert.equals(1, RuntimeMetrics.get("Discovery/ce.hub.Train").count)
        assert.is_true(RuntimeMetrics.get("Discovery/ce.hub.Train").lastTime >= 0)
    end)
end)
