insulate("ce.hub.data.version.VersionUpdater", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPVer = _G.EEPVer

    before_each(function ()
        clearModule("ce.hub.data.version.VersionUpdater")
        clearModule("ce.hub.data.version.VersionRegistry")
        clearModule("ce.hub.data.version.VersionInfo")

        rawset(_G, "EEPVer", 18.1)
    end)

    after_each(function ()
        rawset(_G, "EEPVer", originalEEPVer)
    end)

    it("updates static version metadata", function ()
        local VersionInfo = require("ce.hub.data.version.VersionInfo")
        local VersionRegistry = require("ce.hub.data.version.VersionRegistry")
        local VersionUpdater = require("ce.hub.data.version.VersionUpdater")

        local getProgramVersionStub = stub(VersionInfo, "getProgramVersion", function () return "1.2.3" end)
        finally(function () getProgramVersionStub:revert() end)

        VersionUpdater.runUpdate()

        local versionInfo = VersionRegistry.get()
        assert.equals("18.1", versionInfo.eepVersion)
        assert.equals(_VERSION, versionInfo.luaVersion)
        assert.equals("1.2.3", versionInfo.singleVersion)
    end)
end)