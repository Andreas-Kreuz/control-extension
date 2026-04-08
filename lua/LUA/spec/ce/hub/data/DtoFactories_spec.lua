insulate("ce.hub.DtoFactories", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.modules.ModuleDtoFactory")
        clearModule("ce.hub.data.scenario.ScenarioDtoFactory")
        clearModule("ce.hub.data.version.VersionDtoFactory")
        clearModule("ce.hub.data.runtime.RuntimeDtoFactory")
    end)

    it("provides metadata and detached DTOs for core ceTypes", function ()
        local ModuleDtoFactory = require("ce.hub.data.modules.ModuleDtoFactory")
        local ScenarioDtoFactory = require("ce.hub.data.scenario.ScenarioDtoFactory")
        local VersionDtoFactory = require("ce.hub.data.version.VersionDtoFactory")
        local RuntimeDtoFactory = require("ce.hub.data.runtime.RuntimeDtoFactory")

        local module = { id = "m-1", enabled = true }
        local ceType, keyId, key, moduleDto = ModuleDtoFactory.createModuleDto("mod.name", module)
        module.enabled = false

        assert.equals("ce.hub.Module", ceType)
        assert.equals("id", keyId)
        assert.equals("m-1", key)
        assert.same({ ceType = "ce.hub.Module", id = "m-1", name = "mod.name", enabled = true }, moduleDto)

        local scenarioRoom, scenarioKeyId, scenarioDtos =
            ScenarioDtoFactory.createScenarioDtoList({
                id = "scenario",
                name = "scenario",
                scenarioName = "Sample",
                timeLapse = 4
            })
        assert.equals("ce.hub.Scenario", scenarioRoom)
        assert.equals("id", scenarioKeyId)
        assert.same({
                        scenario = {
                            ceType = "ce.hub.Scenario",
                            id = "scenario",
                            name = "scenario",
                            scenarioName = "Sample",
                            timeLapse = 4
                        }
                    }, scenarioDtos)

        local versionRoom, versionKeyId, versionDtos =
            VersionDtoFactory.createVersionDtoList({
                eepVersion = "18.1",
                luaVersion = "Lua 5.3",
                singleVersion = "1.2.3"
            })
        assert.equals("ce.hub.EepVersion", versionRoom)
        assert.equals("id", versionKeyId)
        assert.same({
                        versionInfo = {
                            ceType = "ce.hub.EepVersion",
                            id = "versionInfo",
                            name = "versionInfo",
                            eepVersion = "18.1",
                            luaVersion = "Lua 5.3",
                            singleVersion = "1.2.3"
                        }
                    }, versionDtos)

        local runtimeRoom, runtimeKeyId, runtimeDtos =
            RuntimeDtoFactory.createRuntimeDtoList(
                {
                    sample = {
                        id = "sample",
                        count = 2,
                        time = 4,
                        lastTime = 1,
                        extra = true
                    }
                })
        assert.equals("ce.hub.Runtime", runtimeRoom)
        assert.equals("id", runtimeKeyId)
        assert.same({
                        sample = {
                            ceType = "ce.hub.Runtime",
                            id = "sample",
                            count = 2,
                            time = 4,
                            lastTime = 1
                        }
                    }, runtimeDtos)
    end)
end)
