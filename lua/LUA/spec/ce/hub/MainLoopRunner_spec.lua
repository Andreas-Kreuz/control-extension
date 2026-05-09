insulate("MainLoopRunner", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end
    local printStub
    local ioInitInitializeStub

    local function resetCoreModules()
        clearModule("ce.ControlExtension")
        clearModule("ce.hub.ControlExtensionHub")
        clearModule("ce.hub.ModuleRegistry")
        clearModule("ce.hub.MainLoopRunner")
        clearModule("ce.hub.StatePublisherRegistry")
        clearModule("ce.hub.CeHubModule")
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.data.modules.ModulesStatePublisher")
        clearModule("ce.hub.data.version.VersionStatePublisher")
        clearModule("ce.hub.data.modules.ModuleDtoFactory")
        clearModule("ce.hub.data.version.VersionDtoFactory")
        clearModule("ce.hub.data.modules.ModulesDataCollector")
        clearModule("ce.hub.data.version.VersionDataCollector")
        clearModule("ce.hub.data.version.VersionInfo")
        clearModule("ce.hub.data.runtime.RuntimeDataCollector")
        clearModule("ce.hub.data.runtime.RuntimeMetrics")
        clearModule("ce.hub.data.runtime.RuntimeDtoFactory")
        clearModule("ce.hub.data.runtime.RuntimeStatePublisher")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.ServerExchangeFileIo")
        clearModule("ce.databridge.IncomingCommandFileReader")
        clearModule("ce.databridge.SafeFileIo")
        clearModule("ce.databridge.LogOutputFileWriter")
        clearModule("ce.databridge.IoInit")
        clearModule("ce.databridge.ExchangeDirRegistry")
        clearModule("ce.databridge.IncomingCommandExecutor")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.databridge.DataStoreFileWriter")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.util.ProtectedExecution")
        clearModule("ce.hub.util.TimedExecution")
    end

    before_each(function ()
        printStub = stub(_G, "print")
        resetCoreModules()
        require("ce.hub.eep.EepSimulator")
        local IoInit = require("ce.databridge.IoInit")
        ioInitInitializeStub = stub(IoInit, "initialize", function () end)
    end)

    after_each(function ()
        if printStub then
            printStub:revert()
            printStub = nil
        end
        if ioInitInitializeStub then
            ioInitInitializeStub:revert()
            ioInitInitializeStub = nil
        end
    end)

    it("runs modules, state publishers and io on every ControlExtension cycle", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local ControlExtension = require("ce.ControlExtension")
        local ModuleRegistry = require("ce.hub.ModuleRegistry")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local DataStoreFileWriter = require("ce.databridge.DataStoreFileWriter")
        local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
        local communicateCalls = 0
        local commandReadCalls = 0
        local dataStoreWriteCalls = 0
        local moduleInitCalls = 0
        local moduleRunCalls = 0
        local publisherInitCalls = 0
        local publisherSyncCalls = 0
        local capturedRuntimeEvents = {}

        local testModule = {
            id = "spec-test-module-1",
            name = "spec.TestCeModule",
            enabled = true,
            init = function () moduleInitCalls = moduleInitCalls + 1 end,
            run = function () moduleRunCalls = moduleRunCalls + 1 end
        }
        local testStatePublisher = {
            name = "spec.TestStatePublisher",
            initialize = function () publisherInitCalls = publisherInitCalls + 1 end,
            syncState = function ()
                publisherSyncCalls = publisherSyncCalls + 1
            end
        }

        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, element)
            if ceType ~= "ce.hub.Runtime" then return end
            capturedRuntimeEvents[#capturedRuntimeEvents + 1] = element or {
                keyId = keyId,
                id = key
            }
        end)
        local printEventCounterStub = stub(DataChangeBus, "printEventCounter", function () end)

        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function ()
                                                            commandReadCalls = commandReadCalls + 1
                                                        end)
        local isServerReadyStub = stub(ServerExchangeCoordinator, "isServerReady", function () return true end)
        local runServerOutputCycleStub = stub(ServerExchangeCoordinator, "runServerOutputCycle", function ()
            communicateCalls = communicateCalls + 1
            return { encodeTime = 0.003, writeTime = 0.004, totalTime = 0.01 }
        end)
        local writeStub = stub(DataStoreFileWriter, "write",
                               function () dataStoreWriteCalls = dataStoreWriteCalls + 1 end)
        finally(function () fireDataChangedStub:revert() end)
        finally(function () printEventCounterStub:revert() end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)
        finally(function () isServerReadyStub:revert() end)
        finally(function () runServerOutputCycleStub:revert() end)
        finally(function () writeStub:revert() end)

        ModuleRegistry.registerModules(testModule)
        StatePublisherRegistry.registerStatePublishers(testStatePublisher)

        ControlExtension.runTasks(0)
        ControlExtension.runTasks(0)
        ControlExtension.runTasks(0)

        assert.equals(1, moduleInitCalls)
        assert.equals(3, moduleRunCalls)
        assert.equals(1, publisherInitCalls)
        assert.equals(3, publisherSyncCalls)
        assert.equals(3, commandReadCalls)
        assert.equals(3, communicateCalls)
        assert.equals(0, dataStoreWriteCalls)
        local runtimeEventsById = {}
        for _, event in ipairs(capturedRuntimeEvents) do
            runtimeEventsById[event.id] = runtimeEventsById[event.id] or {}
            for key, value in pairs(event) do runtimeEventsById[event.id][key] = value end
        end
        assert.is_not_nil(runtimeEventsById["MainLoopRunner.runCycle-OVERALL"])
        assert.equals(1, runtimeEventsById["MainLoopRunner.runCycle-OVERALL"].count)
        assert.equals(1, runtimeEventsById["MainLoopRunner.runCycle-4-syncState"].count)
        assert.equals(1, runtimeEventsById["MainLoopRunner.runCycle-7-serverOutput"].count)
        assert.equals(1, runtimeEventsById["CeModule.spec.TestCeModule.init"].count)
        assert.is_true(RuntimeMetrics.get("StatePublisher.spec.TestStatePublisher.syncState").count == 0)
        assert.equals(0, RuntimeMetrics.get("StatePublisher.spec.TestStatePublisher.syncState").lastTime)
        assert.is_true(RuntimeMetrics.get("CeModule.spec.TestCeModule.init").count > 0)
        assert.is_true(RuntimeMetrics.get("CeModule.spec.TestCeModule.init").lastTime >= 0)
    end)

    it("skips server output while server is deactivated but still reads commands", function ()
        local ControlExtension = require("ce.ControlExtension")
        local ModuleRegistry = require("ce.hub.ModuleRegistry")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
        local communicateCalls = 0
        local commandReadCalls = 0
        local publisherSyncCalls = 0

        local testModule = {
            id = "spec-test-module-2",
            name = "spec.DisabledServerModule",
            enabled = true,
            init = function () end,
            run = function () end
        }
        local testStatePublisher = {
            name = "spec.DisabledServerPublisher",
            initialize = function () end,
            syncState = function ()
                publisherSyncCalls = publisherSyncCalls + 1
            end
        }

        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function ()
                                                            commandReadCalls = commandReadCalls + 1
                                                        end)
        local runServerOutputCycleStub = stub(ServerExchangeCoordinator, "runServerOutputCycle", function ()
            communicateCalls = communicateCalls + 1
            return { encodeTime = 0.003, writeTime = 0.004, totalTime = 0.01 }
        end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)
        finally(function () runServerOutputCycleStub:revert() end)

        ModuleRegistry.registerModules(testModule)
        StatePublisherRegistry.registerStatePublishers(testStatePublisher)
        ControlExtension.deactivateServer()

        ControlExtension.runTasks(3)

        assert.equals(1, publisherSyncCalls)
        assert.equals(1, commandReadCalls)
        assert.equals(0, communicateCalls)
        assert.equals(0, RuntimeMetrics.get("MainLoopRunner.runCycle-7-serverOutput").time)
        assert.equals(0, RuntimeMetrics.get("MainLoopRunner.runCycle-8-dataStoreWrite").time)
        assert.equals(0, RuntimeMetrics.get("MainLoopRunner.runCycle-7-serverOutput").lastTime)
        assert.equals(0, RuntimeMetrics.get("MainLoopRunner.runCycle-8-dataStoreWrite").lastTime)
    end)

    it("writes the DataStore json only on publish cycles when enabled", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        local DataStoreFileWriter = require("ce.databridge.DataStoreFileWriter")
        local dataStoreWriteCalls = 0
        local commandReadCalls = 0
        local communicateCalls = 0

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function () end)
        local printEventCounterStub = stub(DataChangeBus, "printEventCounter", function () end)

        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function ()
                                                            commandReadCalls = commandReadCalls + 1
                                                        end)
        local runServerOutputCycleStub = stub(ServerExchangeCoordinator, "runServerOutputCycle", function ()
            communicateCalls = communicateCalls + 1
            return { encodeTime = 0.003, writeTime = 0.004, totalTime = 0.01 }
        end)
        local writeStub = stub(DataStoreFileWriter, "write",
                               function () dataStoreWriteCalls = dataStoreWriteCalls + 1 end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () printEventCounterStub:revert() end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)
        finally(function () runServerOutputCycleStub:revert() end)
        finally(function () writeStub:revert() end)

        MainLoopRunner.runCycle(5, {}, {}, { enableServer = false, enableDataStoreJson = true })
        MainLoopRunner.runCycle(5, {}, {}, { enableServer = false, enableDataStoreJson = true })

        assert.equals(2, commandReadCalls)
        assert.equals(0, communicateCalls)
        assert.equals(1, dataStoreWriteCalls)
    end)

    it("prints all collected runCycle timings in debug output", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local DataStoreFileWriter = require("ce.databridge.DataStoreFileWriter")
        local printedMessages = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function () end)
        local printEventCounterStub = stub(DataChangeBus, "printEventCounter", function () end)
        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function () end)
        local writeStub = stub(DataStoreFileWriter, "write", function () end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () printEventCounterStub:revert() end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)
        finally(function () writeStub:revert() end)

        printStub:revert()
        printStub = stub(_G, "print", function (message)
            table.insert(printedMessages, tostring(message))
        end)

        local ok, err = pcall(function ()
            MainLoopRunner.runCycle(5, {}, {}, { debug = true, enableServer = false, enableDataStoreJson = true })
        end)

        if not ok then error(err) end

        local runCycleLog
        for _, message in ipairs(printedMessages) do
            if string.find(message, "[#MainLoopRunner] runCycle(5) time:", 1, true) then
                runCycleLog = message
                break
            end
        end

        assert.is_not_nil(runCycleLog)
        assert.is_truthy(string.find(runCycleLog, "1%-initModules:") ~= nil)
        assert.is_truthy(string.find(runCycleLog, "5%-commands:") ~= nil)
        assert.is_truthy(string.find(runCycleLog, "6%-waitForServer:") ~= nil)
        assert.is_truthy(string.find(runCycleLog, "8%-dataStoreWrite:") ~= nil)
    end)

    it("pauses EEP around first initialization when enabled", function ()
        local ControlExtension = require("ce.ControlExtension")
        local ModuleRegistry = require("ce.hub.ModuleRegistry")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local pauseCalls = {}

        local testModule = {
            id = "spec-test-module-3",
            name = "spec.PauseModule",
            enabled = true,
            init = function () end,
            run = function () end
        }

        ModuleRegistry.registerModules(testModule)
        ControlExtension.setPauseEepDuringInitialization(true)
        local runCycleStub = stub(MainLoopRunner, "runCycle", function ()
            assert.equals(1, #pauseCalls)
            assert.equals(1, pauseCalls[1])
            return 0
        end)
        local eepPauseStub = stub(_G, "EEPPause", function (value)
            table.insert(pauseCalls, value)
        end)
        finally(function () runCycleStub:revert() end)
        finally(function () eepPauseStub:revert() end)

        ControlExtension.runTasks(5)

        assert.same({ 1, 0 }, pauseCalls)
    end)

    it("continues later runtime phases after one module run fails", function ()
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local DataStoreFileWriter = require("ce.databridge.DataStoreFileWriter")
        local goodModuleRunCalls = 0
        local publisherSyncCalls = 0
        local commandReadCalls = 0
        local dataStoreWriteCalls = 0

        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function ()
                                                            commandReadCalls = commandReadCalls + 1
                                                        end)
        local writeStub = stub(DataStoreFileWriter, "write", function ()
            dataStoreWriteCalls = dataStoreWriteCalls + 1
        end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)
        finally(function () writeStub:revert() end)

        StatePublisherRegistry.registerStatePublishers({
            name = "spec.IndependentPublisher",
            initialize = function () end,
            syncState = function () publisherSyncCalls = publisherSyncCalls + 1 end
        })

        MainLoopRunner.runCycle(0, { "bad", "good" }, {
            bad = {
                name = "spec.BadModule",
                init = function () end,
                run = function () error("module failed") end
            },
            good = {
                name = "spec.GoodModule",
                init = function () end,
                run = function () goodModuleRunCalls = goodModuleRunCalls + 1 end
            }
        }, { enableServer = false, enableDataStoreJson = true })

        assert.equals(1, goodModuleRunCalls)
        assert.equals(1, publisherSyncCalls)
        assert.equals(1, commandReadCalls)
        assert.equals(1, dataStoreWriteCalls)
    end)

    it("retries failed module and publisher initialization", function ()
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local moduleInitCalls = 0
        local moduleRunCalls = 0
        local publisherInitCalls = 0
        local publisherSyncCalls = 0

        local readAndExecuteIncomingCommandsStub = stub(IncomingCommandFileReader, "readAndExecuteIncomingCommands",
                                                        function () end)
        finally(function () readAndExecuteIncomingCommandsStub:revert() end)

        StatePublisherRegistry.registerStatePublishers({
            name = "spec.RetryPublisher",
            initialize = function ()
                publisherInitCalls = publisherInitCalls + 1
                if publisherInitCalls == 1 then error("publisher init failed") end
            end,
            syncState = function () publisherSyncCalls = publisherSyncCalls + 1 end
        })

        local modules = {
            retry = {
                name = "spec.RetryModule",
                init = function ()
                    moduleInitCalls = moduleInitCalls + 1
                    if moduleInitCalls == 1 then error("module init failed") end
                end,
                run = function () moduleRunCalls = moduleRunCalls + 1 end
            }
        }

        MainLoopRunner.runCycle(5, { "retry" }, modules, { enableServer = false })
        assert.is_false(MainLoopRunner.areModulesInitialized())
        assert.equals(1, moduleInitCalls)
        assert.equals(0, moduleRunCalls)
        assert.equals(1, publisherInitCalls)
        assert.equals(0, publisherSyncCalls)

        MainLoopRunner.runCycle(5, { "retry" }, modules, { enableServer = false })
        assert.is_true(MainLoopRunner.areModulesInitialized())
        assert.equals(2, moduleInitCalls)
        assert.equals(1, moduleRunCalls)
        assert.equals(2, publisherInitCalls)
        assert.equals(1, publisherSyncCalls)
    end)

    it("runTasks catches remaining runCycle errors and resumes EEP", function ()
        local ControlExtension = require("ce.ControlExtension")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local pauseCalls = {}

        ControlExtension.setPauseEepDuringInitialization(true)
        local runCycleStub = stub(MainLoopRunner, "runCycle", function ()
            error("cycle failed")
        end)
        local eepPauseStub = stub(_G, "EEPPause", function (value)
            table.insert(pauseCalls, value)
        end)
        finally(function () runCycleStub:revert() end)
        finally(function () eepPauseStub:revert() end)

        local ok, result = pcall(function () return ControlExtension.runTasks(5) end)

        assert.is_true(ok)
        assert.is_nil(result)
        assert.same({ 1, 0 }, pauseCalls)
    end)
end)
