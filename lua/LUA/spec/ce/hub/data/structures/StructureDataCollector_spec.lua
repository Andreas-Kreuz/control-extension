insulate("ce.hub.data.structures.StructureDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local states

    before_each(function ()
        clearModule("ce.hub.data.structures.StructureDataCollector")

        states = {
            ["#3"] = {
                hasLight = true,
                hasSmoke = true,
                hasFire = true,
                light = true,
                smoke = false,
                fire = false,
                pos = { 1.111, 2.222, 3.333 },
                rot = { 4.444, 5.555, 6.666 },
                modelType = 22,
                tag = "Depot"
            },
            ["#4"] = {
                light = false,
                smoke = false,
                fire = false,
                pos = { 7.777, 8.888, 9.999 },
                rot = { 0.111, 0.222, 0.333 },
                modelType = 23,
                tag = ""
            }
        }

        stub(_G, "EEPStructureGetLight", function (name)
            local entry = states[name]
            if not entry or entry.hasLight ~= true then return false, false end
            return true, entry.light
        end)
        stub(_G, "EEPStructureGetSmoke", function (name)
            local entry = states[name]
            if not entry or entry.hasSmoke ~= true then return false, false end
            return true, entry.smoke
        end)
        stub(_G, "EEPStructureGetFire", function (name)
            local entry = states[name]
            if not entry or entry.hasFire ~= true then return false, false end
            return true, entry.fire
        end)
        stub(_G, "EEPStructureGetPosition", function (name)
            local entry = states[name]
            if not entry then return false end
            return true, entry.pos[1], entry.pos[2], entry.pos[3]
        end)
        stub(_G, "EEPStructureGetRotation", function (name)
            local entry = states[name]
            if not entry then return false end
            return true, entry.rot[1], entry.rot[2], entry.rot[3]
        end)
        stub(_G, "EEPStructureGetModelType", function (name)
            local entry = states[name]
            if not entry then return false end
            return true, entry.modelType
        end)
        stub(_G, "EEPStructureGetTagText", function (name)
            local entry = states[name]
            if not entry then return false end
            return true, entry.tag
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

    it("collects initial structures with static and dynamic fields", function ()
        local StructureDataCollector = require("ce.hub.data.structures.StructureDataCollector")

        local structures = StructureDataCollector.collectInitialStructures()

        assert.same(2, #structures)
        assert.same({
                        id = "#3",
                        name = "#3",
                        pos_x = 1.11,
                        pos_y = 2.22,
                        pos_z = 3.33,
                        rot_x = 4.44,
                        rot_y = 5.55,
                        rot_z = 6.67,
                        modelType = 22,
                        modelTypeText = "Immobilie",
                        tag = "Depot",
                        light = true,
                        smoke = false,
                        fire = false
                    }, structures[1])
        assert.same({
                        id = "#4",
                        name = "#4",
                        pos_x = 7.78,
                        pos_y = 8.89,
                        pos_z = 10,
                        rot_x = 0.11,
                        rot_y = 0.22,
                        rot_z = 0.33,
                        modelType = 23,
                        modelTypeText = "Landschaftselement/Fauna",
                        tag = "",
                        light = false,
                        smoke = false,
                        fire = false
                    }, structures[2])
    end)

    it("refreshes only dirty structures, updates dynamic values and keeps modelType initial-only", function ()
        local StructureDataCollector = require("ce.hub.data.structures.StructureDataCollector")

        local structures = StructureDataCollector.collectInitialStructures()
        states["#3"].smoke = true
        states["#3"].pos = { 11.111, 12.222, 13.333 }
        states["#3"].rot = { 14.444, 15.555, 16.666 }
        states["#3"].tag = "Depot Nord"
        states["#3"].modelType = 23

        local dirtyStructures = StructureDataCollector.refreshDirtyStructures(structures)

        assert.same(1, #dirtyStructures)
        assert.is_true(dirtyStructures[1] == structures[1])
        assert.is_true(structures[1].smoke)
        assert.is_false(structures[1].fire)
        assert.same(11.11, structures[1].pos_x)
        assert.same(12.22, structures[1].pos_y)
        assert.same(13.33, structures[1].pos_z)
        assert.same(14.44, structures[1].rot_x)
        assert.same(15.55, structures[1].rot_y)
        assert.same(16.67, structures[1].rot_z)
        assert.same("Depot Nord", structures[1].tag)
        assert.same(22, structures[1].modelType)
        assert.same("Immobilie", structures[1].modelTypeText)
    end)
end)
