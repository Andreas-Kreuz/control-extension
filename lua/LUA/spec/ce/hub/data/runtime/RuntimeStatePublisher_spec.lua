insulate("RuntimeStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPGetFramesPerSecond = _G.EEPGetFramesPerSecond
    local originalEEPGetCurrentFrame = _G.EEPGetCurrentFrame
    local originalEEPGetCurrentRenderFrame = _G.EEPGetCurrentRenderFrame

    before_each(function ()
        clearModule("ce.hub.data.runtime.RuntimeDataCollector")
        clearModule("ce.hub.data.runtime.RuntimeDtoFactory")
        clearModule("ce.hub.data.runtime.RuntimeStatePublisher")
        clearModule("ce.hub.publish.DataChangeBus")

        _G.EEPGetFramesPerSecond = function () return 60 end
        _G.EEPGetCurrentFrame = function () return 15 end
        _G.EEPGetCurrentRenderFrame = function () return 15948 end
    end)

    after_each(function ()
        _G.EEPGetFramesPerSecond = originalEEPGetFramesPerSecond
        _G.EEPGetCurrentFrame = originalEEPGetCurrentFrame
        _G.EEPGetCurrentRenderFrame = originalEEPGetCurrentRenderFrame
    end)

    it("publishes the last completed runtime snapshot only once", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local RuntimeDataCollector = require("ce.hub.data.runtime.RuntimeDataCollector")
        local RuntimeStatePublisher = require("ce.hub.data.runtime.RuntimeStatePublisher")
        local published = {}

        DataChangeBus.fireListChange = function (ceType, keyId, list)
            table.insert(published, { ceType = ceType, keyId = keyId, list = list })
        end

        RuntimeStatePublisher.syncState()
        assert.equals(0, #published)

        RuntimeDataCollector.setLastCycleRuntimeEntries(
            {
                sample = {
                    ceType = "ce.hub.Runtime",
                    id = "sample",
                    count = 2,
                    time = 4,
                    lastTime = 1
                }
            }, true)

        RuntimeStatePublisher.syncState()
        assert.equals(1, #published)
        assert.equals("ce.hub.Runtime", published[1].ceType)
        assert.equals("id", published[1].keyId)
        assert.same({
                        sample = {
                            ceType = "ce.hub.Runtime",
                            id = "sample",
                            count = 2,
                            time = 4,
                            lastTime = 1,
                        }
                    }, published[1].list)

        RuntimeStatePublisher.syncState()
        assert.equals(1, #published)
    end)
end)
