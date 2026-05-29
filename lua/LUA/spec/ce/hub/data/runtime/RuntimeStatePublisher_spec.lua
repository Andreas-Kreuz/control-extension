insulate("RuntimeStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local framesPerSecondStub
    local currentFrameStub
    local currentRenderFrameStub

    before_each(function ()
        clearModule("ce.hub.data.runtime.RuntimeUpdater")
        clearModule("ce.hub.data.runtime.RuntimeDtoFactory")
        clearModule("ce.hub.data.runtime.RuntimeStatePublisher")
        clearModule("ce.hub.publish.DataChangeBus")

        framesPerSecondStub = stub(_G, "EEPGetFramesPerSecond", function () return 60 end)
        currentFrameStub = stub(_G, "EEPGetCurrentFrame", function () return 15 end)
        currentRenderFrameStub = stub(_G, "EEPGetCurrentRenderFrame", function () return 15948 end)
    end)

    after_each(function ()
        framesPerSecondStub:revert()
        currentFrameStub:revert()
        currentRenderFrameStub:revert()
    end)

    it("publishes the last completed runtime snapshot only once", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local RuntimeUpdater = require("ce.hub.data.runtime.RuntimeUpdater")
        local RuntimeStatePublisher = require("ce.hub.data.runtime.RuntimeStatePublisher")
        local published = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            for _, dto in pairs(list or {}) do
                table.insert(published, { ceType = ceType, keyId = keyId, key = dto[keyId], dto = dto })
            end
        end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(published, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        local fireDataRemovedStub = stub(DataChangeBus, "fireDataRemoved", function ()
            error("runtime entries must not be removed when no completed snapshot is available")
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)
        finally(function () fireDataRemovedStub:revert() end)

        RuntimeStatePublisher.syncState()
        assert.equals(0, #published)

        RuntimeUpdater.setLastCycleRuntimeEntries(
            {
                sample = {
                    ceType = "ce.hub.Runtime",
                    id = "sample",
                    count = 2,
                    time = 4,
                    lastTime = 1
                }
            }, true)

        RuntimeUpdater.runUpdate()
        RuntimeStatePublisher.syncState()
        assert.equals(1, #published)
        assert.equals("ce.hub.Runtime", published[1].ceType)
        assert.equals("id", published[1].keyId)
        assert.equals("sample", published[1].key)
        assert.same({
                        ceType = "ce.hub.Runtime",
                        id = "sample",
                        count = 2,
                        time = 4,
                        lastTime = 1,
                    }, published[1].dto)

        RuntimeUpdater.runUpdate()
        RuntimeStatePublisher.syncState()
        assert.equals(1, #published)
    end)
end)
