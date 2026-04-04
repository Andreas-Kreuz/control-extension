insulate("FrameDataStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPGetFramesPerSecond = _G.EEPGetFramesPerSecond
    local originalEEPGetCurrentFrame = _G.EEPGetCurrentFrame
    local originalEEPGetCurrentRenderFrame = _G.EEPGetCurrentRenderFrame

    before_each(function ()
        clearModule("ce.hub.data.framedata.FrameDataDtoFactory")
        clearModule("ce.hub.data.framedata.FrameDataStatePublisher")
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

    it("publishes frame data as a single entry", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local FrameDataStatePublisher = require("ce.hub.data.framedata.FrameDataStatePublisher")
        local published = {}

        DataChangeBus.fireListChange = function (ceType, keyId, list)
            table.insert(published, { ceType = ceType, keyId = keyId, list = list })
        end

        FrameDataStatePublisher.syncState()
        assert.equals(1, #published)
        assert.equals("ce.hub.FrameData", published[1].ceType)
        assert.equals("id", published[1].keyId)
        assert.same({
                        {
                            ceType = "ce.hub.FrameData",
                            id = "frameData",
                            framesPerSecond = 60,
                            currentFrame = 15,
                            currentRenderFrame = 15948
                        }
                    }, published[1].list)
    end)

    it("publishes nil values when EEP functions are not available", function ()
        _G.EEPGetFramesPerSecond = nil
        _G.EEPGetCurrentFrame = nil
        _G.EEPGetCurrentRenderFrame = nil

        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local FrameDataStatePublisher = require("ce.hub.data.framedata.FrameDataStatePublisher")
        local published = {}

        DataChangeBus.fireListChange = function (ceType, keyId, list)
            table.insert(published, { ceType = ceType, keyId = keyId, list = list })
        end

        FrameDataStatePublisher.syncState()
        assert.equals(1, #published)
        assert.same({
                        {
                            ceType = "ce.hub.FrameData",
                            id = "frameData"
                        }
                    }, published[1].list)
    end)
end)
