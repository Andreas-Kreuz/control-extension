insulate("ce.mods.road.tipptext.RoadTippTextCoordinator", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.hub.data.structures.SignalHousingStructure")
        clearModule("ce.mods.road.IntersectionSettings")
        clearModule("ce.mods.road.Intersection")
        clearModule("ce.mods.road.TrafficLight")
        clearModule("ce.mods.road.tipptext.RoadTippTextOptions")
        clearModule("ce.mods.road.tipptext.RoadSignalTippTextComposer")
        clearModule("ce.mods.road.tipptext.RoadOverviewTippTextComposer")
        clearModule("ce.mods.road.tipptext.RoadTippTextGenerator")
        clearModule("ce.mods.road.tipptext.RoadTippTextCoordinator")
        clearModule("ce.mods.road.CeRoadModule")
        require("ce.hub.eep.EepSimulator")
    end)

    it("is called by CeRoadModule.run after phase switching", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local Intersection = require("ce.mods.road.Intersection")
        local RoadTippTextCoordinator = require("ce.mods.road.tipptext.RoadTippTextCoordinator")
        local calls = {}

        local switchStub = stub(Intersection, "switchPhases", function () table.insert(calls, "switch") end)
        local runStub = stub(RoadTippTextCoordinator, "run", function () table.insert(calls, "tipp") end)
        finally(function ()
            switchStub:revert()
            runStub:revert()
        end)

        CeRoadModule.run()

        assert.are.same({ "switch", "tipp" }, calls)
    end)

    it("does not update global signal tipp texts in Intersection.switchPhases", function ()
        local Intersection = require("ce.mods.road.Intersection")

        local showStub = stub(_G, "EEPShowInfoSignal", function () error("unexpected signal info call") end)
        local changeStub = stub(_G, "EEPChangeInfoSignal", function () error("unexpected signal text call") end)
        finally(function ()
            showStub:revert()
            changeStub:revert()
        end)

        Intersection.switchPhases()
    end)

    it("refreshes road state before fingerprinting", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
        local calls = {}

        local refreshStub = stub(Intersection, "refreshRoadState", function () table.insert(calls, "refresh") end)
        local needsRefreshStub = stub(RoadTippTextGenerator, "needsRoadStateRefresh", function () return true end)
        local fingerprintStub = stub(RoadTippTextGenerator, "fingerprint", function ()
            table.insert(calls, "fingerprint")
            return "fp"
        end)
        local generateStub = stub(RoadTippTextGenerator, "generate", function ()
            return {
                signals = {},
                structures = {}
            }
        end)
        finally(function ()
            refreshStub:revert()
            needsRefreshStub:revert()
            fingerprintStub:revert()
            generateStub:revert()
        end)

        require("ce.mods.road.tipptext.RoadTippTextCoordinator").run()

        assert.equals("refresh", calls[1])
        assert.equals("fingerprint", calls[2])
    end)

    it("does not refresh road state when generator does not need it", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")

        local refreshStub = stub(Intersection, "refreshRoadState", function ()
            error("unexpected road state refresh")
        end)
        local needsRefreshStub = stub(RoadTippTextGenerator, "needsRoadStateRefresh", function () return false end)
        local fingerprintStub = stub(RoadTippTextGenerator, "fingerprint", function () return "fp" end)
        local generateStub = stub(RoadTippTextGenerator, "generate", function ()
            return {
                signals = {},
                structures = {}
            }
        end)
        finally(function ()
            refreshStub:revert()
            needsRefreshStub:revert()
            fingerprintStub:revert()
            generateStub:revert()
        end)

        require("ce.mods.road.tipptext.RoadTippTextCoordinator").run()
    end)

    it("skips apply when the generator fingerprint is unchanged", function ()
        local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
        local generateCalls = 0
        local showCalls = 0

        local fingerprintStub = stub(RoadTippTextGenerator, "fingerprint", function () return "same" end)
        local generateStub = stub(RoadTippTextGenerator, "generate", function ()
            generateCalls = generateCalls + 1
            return {
                signals = {
                    [10] = {
                        visible = true,
                        text = "<j>Signal: 10"
                    }
                },
                structures = {}
            }
        end)
        local showStub = stub(_G, "EEPShowInfoSignal", function () showCalls = showCalls + 1 end)
        finally(function ()
            fingerprintStub:revert()
            generateStub:revert()
            showStub:revert()
        end)

        local coordinator = require("ce.mods.road.tipptext.RoadTippTextCoordinator")
        coordinator.run()
        coordinator.run()

        assert.equals(1, generateCalls)
        assert.equals(1, showCalls)
    end)

    it("applies generated signal and structure states when the fingerprint changes", function ()
        local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
        local fingerprint = "a"
        local shownSignals = {}
        local changedSignals = {}
        local shownStructures = {}
        local changedStructures = {}

        local fingerprintStub = stub(RoadTippTextGenerator, "fingerprint", function () return fingerprint end)
        local generateStub = stub(RoadTippTextGenerator, "generate", function ()
            return {
                signals = {
                    [11] = {
                        visible = true,
                        text = "<j>Signal: 11"
                    }
                },
                structures = {
                    ["#Box"] = {
                        visible = true,
                        text = "<j>Immo: #Box"
                    }
                }
            }
        end)
        local showSignalStub = stub(_G, "EEPShowInfoSignal", function (signalId, visible)
            shownSignals[signalId] = visible
        end)
        local changeSignalStub = stub(_G, "EEPChangeInfoSignal", function (signalId, text)
            changedSignals[signalId] = text
        end)
        local showStructureStub = stub(_G, "EEPShowInfoStructure", function (structureName, visible)
            shownStructures[structureName] = visible
        end)
        local changeStructureStub = stub(_G, "EEPChangeInfoStructure", function (structureName, text)
            changedStructures[structureName] = text
        end)
        finally(function ()
            fingerprintStub:revert()
            generateStub:revert()
            showSignalStub:revert()
            changeSignalStub:revert()
            showStructureStub:revert()
            changeStructureStub:revert()
        end)

        local coordinator = require("ce.mods.road.tipptext.RoadTippTextCoordinator")
        coordinator.run()
        fingerprint = "b"
        coordinator.run()

        assert.is_true(shownSignals[11])
        assert.equals("<j>Signal: 11", changedSignals[11])
        assert.is_true(shownStructures["#Box"])
        assert.equals("<j>Immo: #Box", changedStructures["#Box"])
    end)

    it("clears targets that disappear from generated output", function ()
        local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
        local fingerprint = "a"
        local firstRun = true
        local shownSignals = {}
        local changedSignals = {}

        local fingerprintStub = stub(RoadTippTextGenerator, "fingerprint", function () return fingerprint end)
        local generateStub = stub(RoadTippTextGenerator, "generate", function ()
            if firstRun then
                firstRun = false
                return {
                    signals = {
                        [12] = {
                            visible = true,
                            text = "<j>Signal: 12"
                        }
                    },
                    structures = {}
                }
            end
            return {
                signals = {},
                structures = {}
            }
        end)
        local showStub = stub(_G, "EEPShowInfoSignal", function (signalId, visible)
            shownSignals[signalId] = visible
        end)
        local changeStub = stub(_G, "EEPChangeInfoSignal", function (signalId, text)
            changedSignals[signalId] = text
        end)
        finally(function ()
            fingerprintStub:revert()
            generateStub:revert()
            showStub:revert()
            changeStub:revert()
        end)

        local coordinator = require("ce.mods.road.tipptext.RoadTippTextCoordinator")
        coordinator.run()
        fingerprint = "b"
        coordinator.run()

        assert.is_false(shownSignals[12])
        assert.equals("", changedSignals[12])
    end)

    it("applies initial clears for managed signal and structure targets after reload", function ()
        local Signal = require("ce.hub.data.signals.Signal")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local shownSignals = {}
        local changedSignals = {}
        local shownStructures = {}
        local changedStructures = {}

        local signal = Signal:new(13)
        signal:seedTippText("")
        signal:seedTippTextVisible(false)
        SignalRegistry.add(signal)

        local structure = Structure:new("#13", "#13_Gehaeuse")
        structure:setGsbname("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        structure:seedTippText("")
        structure:seedTippTextVisible(false)
        StructureRegistry.add(structure)

        local showSignalStub = stub(_G, "EEPShowInfoSignal", function (signalId, visible)
            shownSignals[signalId] = visible
        end)
        local changeSignalStub = stub(_G, "EEPChangeInfoSignal", function (signalId, text)
            changedSignals[signalId] = text
        end)
        local showStructureStub = stub(_G, "EEPShowInfoStructure", function (structureName, visible)
            shownStructures[structureName] = visible
        end)
        local changeStructureStub = stub(_G, "EEPChangeInfoStructure", function (structureName, text)
            changedStructures[structureName] = text
        end)
        finally(function ()
            showSignalStub:revert()
            changeSignalStub:revert()
            showStructureStub:revert()
            changeStructureStub:revert()
        end)

        require("ce.mods.road.tipptext.RoadTippTextCoordinator").run()

        assert.is_false(shownSignals[13])
        assert.is_nil(changedSignals[13])
        assert.is_false(shownStructures["#13_Gehaeuse"])
        assert.is_nil(changedStructures["#13_Gehaeuse"])
    end)

    it("applies initial clears for newly discovered managed targets", function ()
        local Signal = require("ce.hub.data.signals.Signal")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local coordinator = require("ce.mods.road.tipptext.RoadTippTextCoordinator")
        local shownSignals = {}
        local changedSignals = {}
        local shownStructures = {}
        local changedStructures = {}

        local showSignalStub = stub(_G, "EEPShowInfoSignal", function (signalId, visible)
            shownSignals[signalId] = visible
        end)
        local changeSignalStub = stub(_G, "EEPChangeInfoSignal", function (signalId, text)
            changedSignals[signalId] = text
        end)
        local showStructureStub = stub(_G, "EEPShowInfoStructure", function (structureName, visible)
            shownStructures[structureName] = visible
        end)
        local changeStructureStub = stub(_G, "EEPChangeInfoStructure", function (structureName, text)
            changedStructures[structureName] = text
        end)
        finally(function ()
            showSignalStub:revert()
            changeSignalStub:revert()
            showStructureStub:revert()
            changeStructureStub:revert()
        end)

        coordinator.run()

        local signal = Signal:new(14)
        signal:seedTippText("")
        signal:seedTippTextVisible(false)
        SignalRegistry.add(signal)

        local structure = Structure:new("#14", "#14_Gehaeuse")
        structure:setGsbname("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        structure:seedTippText("")
        structure:seedTippTextVisible(false)
        StructureRegistry.add(structure)

        coordinator.run()

        assert.is_false(shownSignals[14])
        assert.is_nil(changedSignals[14])
        assert.is_false(shownStructures["#14_Gehaeuse"])
        assert.is_nil(changedStructures["#14_Gehaeuse"])
    end)
end)
