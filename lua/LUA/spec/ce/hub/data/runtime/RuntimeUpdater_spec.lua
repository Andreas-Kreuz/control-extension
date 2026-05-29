---@diagnostic disable: need-check-nil
insulate("RuntimeUpdater", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.runtime.RuntimeUpdater")
        clearModule("ce.hub.data.runtime.RuntimeRegistry")
    end)

    it("stores only the latest publishable snapshot", function ()
        local RuntimeUpdater = require("ce.hub.data.runtime.RuntimeUpdater")
        local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")

        RuntimeUpdater.setLastCycleRuntimeEntries(
            {
                sample = { id = "sample", count = 1, time = 2, lastTime = 2 }
            }, false)
        RuntimeUpdater.runUpdate()

        assert.is_nil(RuntimeRegistry.get("sample"))

        local source = {
            sample = { id = "sample", count = 2, time = 4, lastTime = 1 }
        }
        RuntimeUpdater.setLastCycleRuntimeEntries(source, true)
        source.sample.count = 99

        RuntimeUpdater.runUpdate()

        local entry = RuntimeRegistry.get("sample")
        assert.is_not_nil(entry)
        assert.equals(2, entry.count)
        assert.equals(4, entry.time)
        assert.equals(1, entry.lastTime)
    end)
end)