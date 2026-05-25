insulate("ce.hub.HubBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.scenario.Scenario")
        clearModule("ce.hub.data.scenario.ScenarioRegistry")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainRollingStockStore")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")
    end)

    it("registers commands for dynamic update selection", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")

        HubBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands(
            "HubInterestSync.startSyncFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_true(InterestSyncRegistry.isSelected(HubCeTypes.Train, "T1"))

        IncomingCommandExecutor.executeIncomingCommands(
            "HubInterestSync.stopSyncFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_false(InterestSyncRegistry.isSelected(HubCeTypes.Train, "T1"))
    end)

    it("routes WebApp EEP setters through data facade commands without EEP reads", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local getTrainSpeedStub = stub(_G, "EEPGetTrainSpeed", function () error("unexpected EEPGetTrainSpeed") end)
        local getRollingStockActiveStub = stub(_G, "EEPRollingstockGetActive", function ()
            error("unexpected EEPRollingstockGetActive")
        end)
        finally(function ()
            getTrainSpeedStub:revert()
            getRollingStockActiveStub:revert()
        end)

        EepSimulator.simulateAddTrain("#CommandTrain", "CommandStock")
        TrainRegistry.seedFromSnapshot({
            name = "#CommandTrain",
            targetSpeed = 0,
            couplingFront = 0,
            couplingRear = 1,
            lights = { ["2"] = false },
            active = false
        })
        RollingStockRegistry.seedFromSnapshot({
            rollingStockName = "CommandStock",
            axisValues = { ["2"] = 0 },
            active = false
        })
        HubBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands(table.concat({
            "Train.setActiveByName|#CommandTrain",
            "RollingStock.setActiveByName|CommandStock",
            "Train.setSpeedByName|#CommandTrain|42|true",
            "Train.setCouplingFrontByName|#CommandTrain|true",
            "Train.setCouplingRearByName|#CommandTrain|false",
            "Train.setLightByName|#CommandTrain|true|2",
            "RollingStock.setAxisByNumberByName|CommandStock|2|77"
        }, "\n"))

        local scenario = ScenarioRegistry.get()
        local train = TrainRegistry.get("#CommandTrain")
        local rollingStock = RollingStockRegistry.get("CommandStock")
        assert.equals("#CommandTrain", scenario:peekActiveTrain())
        assert.equals("CommandStock", scenario:peekActiveRollingStock())
        assert.is_true(train:peekActive())
        assert.equals(42, train:peekTargetSpeed())
        assert.equals(1, train:peekCouplingFront())
        assert.equals(0, train:peekCouplingRear())
        assert.is_true(train:peekLight(2))
        assert.is_true(rollingStock:peekActive())
        assert.equals(77, rollingStock:peekAxisValues()["2"])
    end)
end)
