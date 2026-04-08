insulate("ce.hub.data.version.VersionDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPVer = _G.EEPVer

    before_each(function ()
        clearModule("ce.hub.data.version.VersionDataCollector")
        clearModule("ce.hub.data.version.VersionInfo")

        rawset(_G, "EEPVer", 18.1)
    end)

    after_each(function ()
        rawset(_G, "EEPVer", originalEEPVer)
    end)

    it("collects static version metadata", function ()
        local VersionInfo = require("ce.hub.data.version.VersionInfo")
        local VersionDataCollector = require("ce.hub.data.version.VersionDataCollector")

        VersionInfo.getProgramVersion = function () return "1.2.3" end

        assert.same({
                        eepVersion = "18.1",
                        luaVersion = _VERSION,
                        singleVersion = "1.2.3"
                    }, VersionDataCollector.collectVersionInfo())
    end)
end)
