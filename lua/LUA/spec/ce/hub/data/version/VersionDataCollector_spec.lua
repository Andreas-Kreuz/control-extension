insulate("ce.hub.data.version.VersionDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPVer = _G.EEPVer
    local originalEEPLng = _G.EEPLng
    local originalEEPGetAnlVer = _G.EEPGetAnlVer
    local originalEEPGetAnlLng = _G.EEPGetAnlLng
    local originalEEPGetAnlName = _G.EEPGetAnlName
    local originalEEPGetAnlPath = _G.EEPGetAnlPath

    before_each(function ()
        clearModule("ce.hub.data.version.VersionDataCollector")
        clearModule("ce.hub.data.version.VersionInfo")

        rawset(_G, "EEPVer", 18.1)
        rawset(_G, "EEPLng", "GER")
        rawset(_G, "EEPGetAnlVer", function () return 18.2 end)
        rawset(_G, "EEPGetAnlLng", function () return "ENG" end)
        rawset(_G, "EEPGetAnlName", function () return "Sample" end)
        rawset(_G, "EEPGetAnlPath", function () return "C:/Layouts/Sample.anl3" end)
    end)

    after_each(function ()
        rawset(_G, "EEPVer", originalEEPVer)
        rawset(_G, "EEPLng", originalEEPLng)
        rawset(_G, "EEPGetAnlVer", originalEEPGetAnlVer)
        rawset(_G, "EEPGetAnlLng", originalEEPGetAnlLng)
        rawset(_G, "EEPGetAnlName", originalEEPGetAnlName)
        rawset(_G, "EEPGetAnlPath", originalEEPGetAnlPath)
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
