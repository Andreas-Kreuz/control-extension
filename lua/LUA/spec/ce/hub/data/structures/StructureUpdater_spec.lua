insulate("ce.hub.data.structures.StructureUpdater", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local structureGetLightStub
    local structureGetSmokeStub
    local structureGetFireStub
    local structureGetTagTextStub
    local structureGetPositionStub
    local structureGetRotationStub

    before_each(function ()
        clearModule("ce.hub.data.HubCeTypes")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.data.structures.Structure")
        clearModule("ce.hub.data.structures.StructureDiscovery")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.hub.data.structures.StructureUpdater")
        clearModule("ce.hub.options.HubOptionDefaults")
        clearModule("ce.hub.options.HubOptionsRegistry")
        clearModule("ce.hub.sync.SyncPolicy")

        structureGetLightStub = stub(_G, "EEPStructureGetLight", function () return true, true end)
        structureGetSmokeStub = stub(_G, "EEPStructureGetSmoke", function () return true, false end)
        structureGetFireStub = stub(_G, "EEPStructureGetFire", function () return true, false end)
        structureGetTagTextStub = stub(_G, "EEPStructureGetTagText", function () return true, "tag=value," end)
        structureGetPositionStub = stub(_G, "EEPStructureGetPosition", function ()
            return true, 1.111, 2.222, 3.333
        end)
        structureGetRotationStub = stub(_G, "EEPStructureGetRotation", function ()
            return true, 4.444, 5.555, 6.666
        end)
    end)

    after_each(function ()
        structureGetLightStub:revert()
        structureGetSmokeStub:revert()
        structureGetFireStub:revert()
        structureGetTagTextStub:revert()
        structureGetPositionStub:revert()
        structureGetRotationStub:revert()
    end)

    local function addStructure(idOrGsbname, name, gsbname)
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local id = name and idOrGsbname or "#3"
        local structure = Structure:new(id, name or "#3_Ampelmast")
        structure:setGsbname(name and gsbname or idOrGsbname)
        StructureRegistry.add(structure)
        structure:resetDirty()
        return structure
    end

    it("does not update oninterest fields for unselected regular structures on every tenth cycle", function ()
        local structure = addStructure()
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        for _ = 1, 9 do
            StructureUpdater.runUpdate()
        end

        assert.stub(structureGetTagTextStub).was_not_called()
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()

        StructureUpdater.runUpdate()

        assert.stub(structureGetTagTextStub).was_not_called()
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()
        assert.same("", structure:peekTag())
        assert.same(0, structure:peekPosX())
        assert.same(0, structure:peekRotX())
    end)

    it("updates tag, position, and rotation for moved structure signal housings every tenth cycle", function ()
        local structure = addStructure("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        for _ = 1, 9 do
            StructureUpdater.runUpdate()
        end

        assert.stub(structureGetTagTextStub).was_not_called()
        assert.stub(structureGetPositionStub).was_not_called()

        StructureUpdater.runUpdate()

        assert.stub(structureGetTagTextStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetPositionStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetRotationStub).was_called_with("#3_Ampelmast")
        assert.same("tag=value,", structure:getTag())
        assert.same(1.11, structure:getPosX())
        assert.same(4.44, structure:getRotX())
        assert.is_true(structure.dirtyFields.tag)
        assert.is_true(structure.dirtyFields.pos_x)
        assert.is_true(structure.dirtyFields.rot_x)
    end)

    it("does not update rotation for unmoved structure signal housings every tenth cycle", function ()
        local structure = addStructure("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        structure:seedPosition(1.111, 2.222, 3.333)
        structure:resetDirty()
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        for _ = 1, 9 do
            StructureUpdater.runUpdate()
        end
        StructureUpdater.runUpdate()

        assert.stub(structureGetTagTextStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetPositionStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetRotationStub).was_not_called()
        assert.is_nil(structure.dirtyFields.rot_x)
    end)

    it("updates only selected structures on regular cycles", function ()
        local tagCalls = {}
        local positionCalls = {}
        structureGetTagTextStub:revert()
        structureGetPositionStub:revert()
        structureGetTagTextStub = stub(_G, "EEPStructureGetTagText", function (name)
            tagCalls[name] = (tagCalls[name] or 0) + 1
            return true, "tag=" .. name .. ","
        end)
        structureGetPositionStub = stub(_G, "EEPStructureGetPosition", function (name)
            positionCalls[name] = (positionCalls[name] or 0) + 1
            return true, 1.111, 2.222, 3.333
        end)

        local selected = addStructure()
        local ignored = addStructure("#4", "#4_Normal")
        local housing = addStructure("#5", "#5_Housing", "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Structure, "#3")
        StructureUpdater.runUpdate()

        assert.same(1, tagCalls[selected.name])
        assert.is_nil(tagCalls[ignored.name])
        assert.is_nil(tagCalls[housing.name])
        assert.same(1, positionCalls[selected.name])
        assert.is_nil(positionCalls[housing.name])
        assert.is_nil(positionCalls[ignored.name])
    end)

    it("updates all structures on regular cycles when a field policy is always", function ()
        local lightCalls = {}
        structureGetLightStub:revert()
        structureGetLightStub = stub(_G, "EEPStructureGetLight", function (name)
            lightCalls[name] = (lightCalls[name] or 0) + 1
            return true, true
        end)

        local HubOptionDefaults = require("ce.hub.options.HubOptionDefaults")
        local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
        local options = HubOptionDefaults.create()
        options.ceTypes.structures.fieldUpdates.light = "always"
        HubOptionsRegistry.setOptions(options)

        local first = addStructure()
        local second = addStructure("#4", "#4_Normal")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        StructureUpdater.runUpdate()

        assert.same(1, lightCalls[first.name])
        assert.same(1, lightCalls[second.name])
    end)

    it("updates position and rotation for selected structures", function ()
        local structure = addStructure()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Structure, "#3")
        StructureUpdater.runUpdate()

        assert.stub(structureGetPositionStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetRotationStub).was_called_with("#3_Ampelmast")
        assert.same(1.11, structure:getPosX())
        assert.same(2.22, structure:getPosY())
        assert.same(3.33, structure:getPosZ())
        assert.same(4.44, structure:getRotX())
        assert.same(5.55, structure:getRotY())
        assert.same(6.67, structure:getRotZ())
        assert.is_true(structure.dirtyFields.pos_x)
        assert.is_true(structure.dirtyFields.pos_y)
        assert.is_true(structure.dirtyFields.pos_z)
        assert.is_true(structure.dirtyFields.rot_x)
        assert.is_true(structure.dirtyFields.rot_y)
        assert.is_true(structure.dirtyFields.rot_z)
    end)

    it("skips all EEP calls in initial update when structures are seeded from anl3", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        StructureDiscovery.initFromAnl3({
            coverage = { structures = true },
            structures = {
                {
                    id = "#3",
                    name = "#3_Ampelmast",
                    gsbname = "Mast.3dm",
                    light = false,
                    smoke = false,
                    fire = false,
                    pos_x = 1.0,
                    pos_y = 2.0,
                    pos_z = 0.0,
                    rot_x = 0.0,
                    rot_y = 0.0,
                    rot_z = 0.0
                }
            }
        })

        StructureUpdater.runInitialUpdate()

        assert.stub(structureGetLightStub).was_not_called()
        assert.stub(structureGetSmokeStub).was_not_called()
        assert.stub(structureGetFireStub).was_not_called()
        assert.stub(structureGetTagTextStub).was_not_called()
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()
    end)

    it("loads only missing fields during initial update after EEP discovery", function ()
        local structure = addStructure()
        structure:seedPosition(10, 20, 30)
        structure:seedRotation(40, 50, 60)
        structure:resetDirty()
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        StructureUpdater.runInitialUpdate()

        assert.stub(structureGetTagTextStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetLightStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetSmokeStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetFireStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()
        assert.same("tag=value,", structure:getTag())
        assert.is_true(structure:getLight())
        assert.is_false(structure:getSmoke())
        assert.is_false(structure:getFire())
        assert.same(10, structure:getPosX())
        assert.same(40, structure:getRotX())
        assert.is_nil(structure.dirtyFields.pos_x)
        assert.is_nil(structure.dirtyFields.rot_x)
    end)

    it("keeps cached position and rotation when EEP does not return values", function ()
        structureGetPositionStub:revert()
        structureGetRotationStub:revert()
        structureGetPositionStub = stub(_G, "EEPStructureGetPosition", function () return false end)
        structureGetRotationStub = stub(_G, "EEPStructureGetRotation", function () return false end)

        local structure = addStructure()
        structure:setPosition(10, 20, 30)
        structure:setRotation(40, 50, 60)
        structure:resetDirty()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Structure, "#3")
        StructureUpdater.runUpdate()

        assert.same(10, structure:getPosX())
        assert.same(20, structure:getPosY())
        assert.same(30, structure:getPosZ())
        assert.same(40, structure:getRotX())
        assert.same(50, structure:getRotY())
        assert.same(60, structure:getRotZ())
        assert.is_nil(structure.dirtyFields.pos_x)
        assert.is_nil(structure.dirtyFields.rot_x)
    end)
end)
