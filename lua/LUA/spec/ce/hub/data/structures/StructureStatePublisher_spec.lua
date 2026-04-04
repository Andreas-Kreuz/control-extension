insulate("ce.hub.data.structures.StructureStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local states

    before_each(function ()
        clearModule("ce.hub.data.structures.StructureStatePublisher")
        clearModule("ce.hub.data.structures.StructureDataCollector")
        clearModule("ce.hub.data.structures.StructureDtoFactory")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        states = {
            ["#2"] = {
                light = true,
                smoke = false,
                fire = false,
                pos = { 1, 2, 3 },
                rot = { 4, 5, 6 },
                modelType = 22,
                tag = "shed"
            },
            ["#3"] = {
                light = false,
                smoke = false,
                fire = false,
                pos = { 7, 8, 9 },
                rot = { 10, 11, 12 },
                modelType = 23,
                tag = "tree"
            }
        }

        stub(_G, "EEPStructureGetLight", function (name)
            local entry = states[name]
            if not entry then return false, false end
            return true, entry.light
        end)
        stub(_G, "EEPStructureGetSmoke", function (name)
            local entry = states[name]
            if not entry then return false, false end
            return true, entry.smoke
        end)
        stub(_G, "EEPStructureGetFire", function (name)
            local entry = states[name]
            if not entry then return false, false end
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

    it("fires initial ceType data and later only dirty ceType data", function ()
        local StructureStatePublisher = require("ce.hub.data.structures.StructureStatePublisher")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        StructureStatePublisher.initialize()

        assert.same({
                        ["#2"] = {
                            ceType = "ce.hub.Structure",
                            id = "#2",
                            name = "#2",
                            pos_x = 1,
                            pos_y = 2,
                            pos_z = 3,
                            rot_x = 4,
                            rot_y = 5,
                            rot_z = 6,
                            modelType = 22,
                            modelTypeText = "Immobilie",
                            tag = "shed",
                            light = true,
                            smoke = false,
                            fire = false
                        },
                        ["#3"] = {
                            ceType = "ce.hub.Structure",
                            id = "#3",
                            name = "#3",
                            pos_x = 7,
                            pos_y = 8,
                            pos_z = 9,
                            rot_x = 10,
                            rot_y = 11,
                            rot_z = 12,
                            modelType = 23,
                            modelTypeText = "Landschaftselement/Fauna",
                            tag = "tree",
                            light = false,
                            smoke = false,
                            fire = false
                        }
                    }, DataStore.getCeType("ce.hub.Structure"))

        states["#2"].fire = true
        StructureStatePublisher.syncState()

        assert.is_true(DataStore.get("ce.hub.Structure", "#2").fire)
        assert.equals("tree", DataStore.get("ce.hub.Structure", "#3").tag)
    end)
end)
