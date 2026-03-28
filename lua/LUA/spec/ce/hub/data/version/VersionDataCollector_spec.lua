insulate("ce.hub.data.version.VersionDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originalEEPVer = _G.EEPVer
    local originalEEPLng = _G.EEPLng
    local originals = {}

    before_each(function ()
        clearModule("ce.hub.data.version.VersionDataCollector")
        clearModule("ce.hub.data.version.VersionInfo")

        _G.EEPVer = 18.1
        _G.EEPLng = "GER"
        originals.EEPGetAnlVer = _G.EEPGetAnlVer
        originals.EEPGetAnlLng = _G.EEPGetAnlLng
        originals.EEPGetAnlName = _G.EEPGetAnlName
        originals.EEPGetAnlPath = _G.EEPGetAnlPath
        _G.EEPGetAnlVer = function () return 18.2 end
        _G.EEPGetAnlLng = function () return "ENG" end
        _G.EEPGetAnlName = function () return "Sample" end
        _G.EEPGetAnlPath = function () return "C:/Layouts/Sample.anl3" end
    end)

    after_each(function ()
        _G.EEPVer = originalEEPVer
        _G.EEPLng = originalEEPLng
        for key, value in pairs(originals) do rawset(_G, key, value) end
    end)

    it("collects optional EEP and layout version metadata", function ()
        local VersionInfo = require("ce.hub.data.version.VersionInfo")
        local VersionDataCollector = require("ce.hub.data.version.VersionDataCollector")

        VersionInfo.getProgramVersion = function () return "1.2.3" end

        assert.same({
                        eepVersion = "18.1",
                        luaVersion = _VERSION,
                        singleVersion = "1.2.3",
                        eepLanguage = "GER",
                        layoutVersion = 18.2,
                        layoutLanguage = "ENG",
                        layoutName = "Sample",
                        layoutPath = "C:/Layouts/Sample.anl3"
                    }, VersionDataCollector.collectVersionInfo())
    end)
end)
