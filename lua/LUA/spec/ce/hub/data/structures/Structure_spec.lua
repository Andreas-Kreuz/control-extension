insulate("ce.hub.data.structures.Structure", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local lightCalls
    local smokeCalls
    local fireCalls
    local positionCalls
    local rotationCalls
    local modelTypeCalls
    local tagCalls

    before_each(function ()
        clearModule("ce.hub.data.structures.Structure")
        lightCalls = 0
        smokeCalls = 0
        fireCalls = 0
        positionCalls = 0
        rotationCalls = 0
        modelTypeCalls = 0
        tagCalls = 0

        stub(_G, "EEPStructureGetLight", function ()
            lightCalls = lightCalls + 1
            return true, true
        end)
        stub(_G, "EEPStructureGetSmoke", function ()
            smokeCalls = smokeCalls + 1
            return true, false
        end)
        stub(_G, "EEPStructureGetFire", function ()
            fireCalls = fireCalls + 1
            return true, true
        end)
        stub(_G, "EEPStructureGetPosition", function ()
            positionCalls = positionCalls + 1
            return true, 1.111, 2.222, 3.333
        end)
        stub(_G, "EEPStructureGetRotation", function ()
            rotationCalls = rotationCalls + 1
            return true, 4.444, 5.555, 6.666
        end)
        stub(_G, "EEPStructureGetModelType", function ()
            modelTypeCalls = modelTypeCalls + 1
            return true, 22
        end)
        stub(_G, "EEPStructureGetTagText", function ()
            tagCalls = tagCalls + 1
            return true, "Depot"
        end)
    end)

    after_each(function ()
        _G.EEPStructureGetLight:revert()
        _G.EEPStructureGetSmoke:revert()
        _G.EEPStructureGetFire:revert()
        _G.EEPStructureGetPosition:revert()
        _G.EEPStructureGetRotation:revert()
        _G.EEPStructureGetModelType:revert()
        _G.EEPStructureGetTagText:revert()
    end)

    it("reads static values during init and tracks dirty fields on refresh", function ()
        local Structure = require("ce.hub.data.structures.Structure")

        local structure = Structure:new("#3")
        -- After new(), all dynamic fields are dirty from init
        structure:resetDirty()
        structure:refresh()

        assert.same(2, lightCalls)
        assert.same(2, smokeCalls)
        assert.same(2, fireCalls)
        assert.same(2, tagCalls)
        assert.same(1, positionCalls)
        assert.same(1, rotationCalls)
        assert.same(1, modelTypeCalls)
        assert.same(1.11, structure.pos_x)
        assert.same(2.22, structure.pos_y)
        assert.same(3.33, structure.pos_z)
        assert.same(4.44, structure.rot_x)
        assert.same(5.55, structure.rot_y)
        assert.same(6.67, structure.rot_z)
        -- No dirty fields since values haven't changed
        assert.is_false(structure:hasDirtyFields())
    end)

    it("skips disabled dynamic fetchers and keeps existing values", function ()
        local Structure = require("ce.hub.data.structures.Structure")
        local disabledOptions = {
            fields = {
                light = { collect = false },
                smoke = { collect = false },
                fire = { collect = false },
                tag = { collect = false }
            }
        }

        local structure = Structure:new("#4", disabledOptions)
        structure:resetDirty()
        structure.light = true
        structure.smoke = true
        structure.fire = true
        structure.tag = "Manual"

        structure:refresh(disabledOptions)

        assert.same(0, lightCalls)
        assert.same(0, smokeCalls)
        assert.same(0, fireCalls)
        assert.same(0, tagCalls)
        assert.same(1, positionCalls)
        assert.same(1, rotationCalls)
        assert.is_true(structure.light)
        assert.is_true(structure.smoke)
        assert.is_true(structure.fire)
        assert.same("Manual", structure.tag)
        assert.is_false(structure:hasDirtyFields())
    end)
end)
