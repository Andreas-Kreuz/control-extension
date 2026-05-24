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

    local function addStructure(gsbname)
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local structure = Structure:new("#3", "#3_Ampelmast")
        structure:setGsbname(gsbname)
        StructureRegistry.add(structure)
        structure:resetDirty()
        return structure
    end

    it("updates oninterest fields for unselected structures every tenth cycle", function ()
        local structure = addStructure()
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        for _ = 1, 9 do
            StructureUpdater.runUpdate()
        end

        assert.stub(structureGetTagTextStub).was_not_called()
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()

        StructureUpdater.runUpdate()

        assert.stub(structureGetTagTextStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetPositionStub).was_called_with("#3_Ampelmast")
        assert.stub(structureGetRotationStub).was_called_with("#3_Ampelmast")
        assert.same("tag=value,", structure:getTag())
        assert.same(1.11, structure:getPosX())
        assert.same(4.44, structure:getRotX())
    end)

    it("updates tags for structure signal housings without structure interest", function ()
        local structure = addStructure("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")

        StructureUpdater.runUpdate()

        assert.stub(structureGetTagTextStub).was_called_with("#3_Ampelmast")
        assert.same("tag=value,", structure:getTag())
        assert.is_true(structure.dirtyFields.tag)
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()
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
                { id = "#3", name = "#3_Ampelmast", gsbname = "Mast.3dm",
                  light = false, smoke = false, fire = false,
                  pos_x = 1.0, pos_y = 2.0, pos_z = 0.0,
                  rot_x = 0.0, rot_y = 0.0, rot_z = 0.0 }
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
