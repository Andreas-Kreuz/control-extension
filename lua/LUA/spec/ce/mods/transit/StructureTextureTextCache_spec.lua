insulate("ce.mods.transit.models.StructureTextureTextCache", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local textureCalls
    local textureStub
    local getTextureStub

    before_each(function ()
        clearModule("ce.mods.transit.models.StructureTextureTextCache")
        clearModule("ce.hub.data.structures.Structure")
        clearModule("ce.hub.data.structures.StructureRegistry")
        textureCalls = {}
        textureStub = stub(_G, "EEPStructureSetTextureText", function (displayStructure, surfaceNumber, text)
            textureCalls[#textureCalls + 1] = {
                displayStructure = displayStructure,
                surfaceNumber = surfaceNumber,
                text = text
            }
            return true
        end)
    end)

    after_each(function ()
        textureStub:revert()
        if getTextureStub then
            getTextureStub:revert()
            getTextureStub = nil
        end
    end)

    it("skips unchanged texture text writes per display surface", function ()
        local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")

        assert.is_true(StructureTextureTextCache.set("#1", 1, "Line A"))
        assert.is_false(StructureTextureTextCache.set("#1", 1, "Line A"))
        assert.is_true(StructureTextureTextCache.set("#1", 1, "Line B"))
        assert.is_true(StructureTextureTextCache.set("#1", 2, "Line A"))

        assert.same({
                        { displayStructure = "#1", surfaceNumber = 1, text = "Line A" },
                        { displayStructure = "#1", surfaceNumber = 1, text = "Line B" },
                        { displayStructure = "#1", surfaceNumber = 2, text = "Line A" }
                    }, textureCalls)
    end)

    it("allows init to reset cached values for a display", function ()
        local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")

        StructureTextureTextCache.set("#1", 1, "Line A")
        StructureTextureTextCache.reset("#1")
        StructureTextureTextCache.set("#1", 1, "Line A")

        assert.equals(1, #textureCalls)
    end)

    it("uses discovered structure texture text before writing after cache reset", function ()
        getTextureStub = stub(_G, "EEPStructureGetTextureText", function (displayStructure, surfaceNumber)
            error("unexpected texture read for " .. tostring(displayStructure) .. ":" .. tostring(surfaceNumber))
        end)
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")
        StructureRegistry.getOrCreate("#1", { textureTexts = { ["1"] = "Line A" } })

        assert.is_false(StructureTextureTextCache.set("#1", 1, "Line A"))
        assert.is_true(StructureTextureTextCache.set("#1", 1, "Line B"))
        StructureTextureTextCache.reset("#1")
        assert.is_false(StructureTextureTextCache.set("#1", 1, "Line B"))

        assert.same({
                        { displayStructure = "#1", surfaceNumber = 1, text = "Line B" }
                    }, textureCalls)
        assert.stub(getTextureStub).was_not_called()
    end)
end)
