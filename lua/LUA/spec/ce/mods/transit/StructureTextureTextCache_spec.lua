insulate("ce.mods.transit.models.StructureTextureTextCache", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local textureCalls
    local textureStub

    before_each(function ()
        clearModule("ce.mods.transit.models.StructureTextureTextCache")
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

        assert.equals(2, #textureCalls)
    end)
end)
