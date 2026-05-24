insulate("ce.hub.data.structures.StructureDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local structureGetModelTypeStub
    local structureGetPositionStub
    local structureGetRotationStub
    local structureGetTagTextStub

    before_each(function ()
        clearModule("ce.hub.data.structures.Structure")
        clearModule("ce.hub.data.structures.StructureDiscovery")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.hub.options.HubOptionDefaults")
        clearModule("ce.hub.options.HubOptionsRegistry")

        structureGetModelTypeStub = stub(_G, "EEPStructureGetModelType", function (name)
            if name == "#2" or name == "#2_Straba Signal Gehaeuse Mast 4" then return true, 22 end
            return false
        end)
        structureGetPositionStub = stub(_G, "EEPStructureGetPosition", function ()
            return true, 1.111, 2.222, 3.333
        end)
        structureGetRotationStub = stub(_G, "EEPStructureGetRotation", function ()
            return true, 4.444, 5.555, 6.666
        end)
        structureGetTagTextStub = stub(_G, "EEPStructureGetTagText", function ()
            return true, "p1=#4,"
        end)
    end)

    after_each(function ()
        structureGetModelTypeStub:revert()
        structureGetPositionStub:revert()
        structureGetRotationStub:revert()
        structureGetTagTextStub:revert()
    end)

    it("loads tags from anl3 structure entries without calling EEP", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

        StructureDiscovery.initFromAnl3({
            coverage = { structures = true },
            structures = {
                {
                    id = "#2",
                    name = "#2_Straba Signal Gehaeuse Mast 4",
                    gsbname = "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm",
                    tag = "p1=#4,"
                }
            }
        })

        assert.equals("p1=#4,", StructureRegistry.forId("#2"):getTag())
        assert.stub(structureGetTagTextStub).was_not_called()
    end)

    it("seeds light, smoke and fire from anl3 without calling EEP", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

        StructureDiscovery.initFromAnl3({
            coverage = { structures = true },
            structures = {
                { id = "#2", name = "#2_Haus", gsbname = "Haus.3dm",
                  light = true, smoke = true, fire = false }
            }
        })

        local structure = StructureRegistry.forId("#2")
        assert.is_true(structure:getLight())
        assert.is_true(structure:getSmoke())
        assert.is_false(structure:getFire())
        assert.stub(structureGetModelTypeStub).was_not_called()
    end)

    it("seeds model type as Immobilie from anl3 without calling EEP", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

        StructureDiscovery.initFromAnl3({
            coverage = { structures = true },
            structures = {
                { id = "#2", name = "#2_Haus", gsbname = "Haus.3dm" }
            }
        })

        local structure = StructureRegistry.forId("#2")
        assert.equals(22, structure:getModelType())
        assert.equals("Immobilie", structure:getModelTypeText())
        assert.stub(structureGetModelTypeStub).was_not_called()
    end)

    it("seeds position and rotation from anl3 without calling EEP", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

        StructureDiscovery.initFromAnl3({
            coverage = { structures = true },
            structures = {
                { id = "#2", name = "#2_Haus", gsbname = "Haus.3dm",
                  pos_x = 142.65, pos_y = -413.43, pos_z = 2.53,
                  rot_x = 0.0, rot_y = 0.0, rot_z = 124.12 }
            }
        })

        local structure = StructureRegistry.forId("#2")
        assert.same(142.65, structure:getPosX())
        assert.same(-413.43, structure:getPosY())
        assert.same(2.53, structure:getPosZ())
        assert.same(124.12, structure:getRotZ())
        assert.stub(structureGetPositionStub).was_not_called()
        assert.stub(structureGetRotationStub).was_not_called()
    end)

    it("marks wasSeededFromAnl3 true after loading structures", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")

        assert.is_false(StructureDiscovery.wasSeededFromAnl3())
        StructureDiscovery.initFromAnl3({ coverage = { structures = true }, structures = {} })
        assert.is_true(StructureDiscovery.wasSeededFromAnl3())
    end)

    it("does not mark wasSeededFromAnl3 when structures coverage is absent", function ()
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")

        StructureDiscovery.initFromAnl3({ coverage = { structures = false }, structures = {} })
        assert.is_false(StructureDiscovery.wasSeededFromAnl3())
    end)

    it("loads tags during normal discovery for known structure signal housings", function ()
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local structure = Structure:new("#2", "#2_Straba Signal Gehaeuse Mast 4")
        structure:setGsbname("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        StructureRegistry.add(structure)

        StructureDiscovery.runInitialDiscovery()

        assert.stub(structureGetTagTextStub).was_called_with("#2_Straba Signal Gehaeuse Mast 4")
        assert.equals("p1=#4,", StructureRegistry.forId("#2"):getTag())
    end)
end)
