insulate("ControlExtension IO init", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.ControlExtension")
        clearModule("ce.hub.ControlExtensionHub")
        clearModule("ce.hub.ModuleRegistry")
        clearModule("ce.hub.MainLoopRunner")
        clearModule("ce.hub.CeHubModule")
        clearModule("ce.databridge.IoInit")
    end)

    it("calls IoInit.initialize before loading ControlExtensionHub", function ()
        local initCalls = 0
        local IoInit = require("ce.databridge.IoInit")
        local hubLoadedDuringInit = false
        local initializeStub = stub(IoInit, "initialize", function ()
            initCalls = initCalls + 1
            hubLoadedDuringInit = package.loaded["ce.hub.ControlExtensionHub"] ~= nil
        end)
        finally(function () initializeStub:revert() end)

        require("ce.ControlExtension")

        assert.equals(1, initCalls)
        assert.is_false(hubLoadedDuringInit)
    end)

    it("does not call IoInit.initialize again from ControlExtension.initTasks", function ()
        local initCalls = 0
        local IoInit = require("ce.databridge.IoInit")
        local initializeStub = stub(IoInit, "initialize", function () initCalls = initCalls + 1 end)
        finally(function () initializeStub:revert() end)

        local ControlExtension = require("ce.ControlExtension")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local initModulesStub = stub(MainLoopRunner, "initModules", function () end)
        finally(function () initModulesStub:revert() end)

        ControlExtension.initTasks()

        assert.equals(1, initCalls)
    end)

    it("does not call IoInit.initialize again from ControlExtension.runTasks", function ()
        local initCalls = 0
        local IoInit = require("ce.databridge.IoInit")
        local initializeStub = stub(IoInit, "initialize", function () initCalls = initCalls + 1 end)
        finally(function () initializeStub:revert() end)

        local ControlExtension = require("ce.ControlExtension")
        local MainLoopRunner = require("ce.hub.MainLoopRunner")
        local areModulesInitializedStub = stub(MainLoopRunner, "areModulesInitialized", function () return true end)
        local runCycleStub = stub(MainLoopRunner, "runCycle", function () return 0 end)
        finally(function () areModulesInitializedStub:revert() end)
        finally(function () runCycleStub:revert() end)

        ControlExtension.runTasks(5)

        assert.equals(1, initCalls)
    end)
end)
