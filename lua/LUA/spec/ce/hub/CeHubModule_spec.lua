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
        clearModule("ce.hub.bridge.HubBridgeConnector")
        clearModule("ce.hub.CeHubModule")
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
            sync = {
                ceTypes = {
                    train = { mode = "all" },
                    time = { mode = "none" }
                }
            }
        }))

        CeHubModule.init()

        local publisherNames = {}
        for _, statePublisher in ipairs(StatePublisherRegistry.getStatePublishers()) do
            publisherNames[statePublisher.name] = true
        end

        assert.is_false(ServerExchangeCoordinator.checkServerStatus)
        assert.is_true(publisherNames["ce.hub.data.trains.TrainsAndTracksStatePublisher"])
        assert.is_nil(publisherNames["ce.hub.data.time.TimeStatePublisher"])
    end)

    it("works with inline hub configuration during module registration", function ()
        local ControlExtension = require("ce.ControlExtension")
        local CeHubModule = require("ce.hub.CeHubModule")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")

        ControlExtension.addModules(
            require("ce.mods.road.CeRoadModule"),
            CeHubModule.setOptions({
                sync = {
                    ceTypes = {
                        train = { mode = "all" },
                        time = { mode = "none" }
                    }
                }
            })
        )

        ControlExtension.runTasks(1)

        local publisherNames = {}
        for _, statePublisher in ipairs(StatePublisherRegistry.getStatePublishers()) do
            publisherNames[statePublisher.name] = true
        end

        assert.is_true(publisherNames["ce.hub.data.trains.TrainsAndTracksStatePublisher"])
        assert.is_true(publisherNames["ce.mods.road.data.RoadStatePublisher"])
        assert.is_nil(publisherNames["ce.hub.data.time.TimeStatePublisher"])
    end)
end)
