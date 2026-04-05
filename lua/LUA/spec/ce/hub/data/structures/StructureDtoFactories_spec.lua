insulate("ce.hub.data.structures.StructureDtoFactories", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.structures.StructureStaticDtoFactory")
        clearModule("ce.hub.data.structures.StructureDynamicDtoFactory")
    end)

    it("projects structures to detached static and dynamic DTO tables", function ()
        local StructureStaticDtoFactory = require("ce.hub.data.structures.StructureStaticDtoFactory")
        local StructureDynamicDtoFactory = require("ce.hub.data.structures.StructureDynamicDtoFactory")
        local structure = {
            id = "#7",
            name = "#7",
            pos_x = 1,
            pos_y = 2,
            pos_z = 3,
            rot_x = 4,
            rot_y = 5,
            rot_z = 6,
            modelType = 22,
            modelTypeText = "Immobilie",
            tag = "alpha",
            light = true,
            smoke = false,
            fire = true
        }

        local staticCeType, staticKeyId, staticKey, staticDto = StructureStaticDtoFactory.createDto(structure)
        local staticListRoom, staticListKeyId, staticDtos = StructureStaticDtoFactory.createDtoList({ structure })
        local dynamicCeType, dynamicKeyId, dynamicKey, dynamicDto = StructureDynamicDtoFactory.createDto(structure)
        local dynamicListRoom, dynamicListKeyId, dynamicDtos = StructureDynamicDtoFactory.createDtoList({ structure })
        structure.tag = "changed"

        assert.equals("ce.hub.StructureStatic", staticCeType)
        assert.equals("id", staticKeyId)
        assert.equals("#7", staticKey)
        assert.same({
                        ceType = "ce.hub.StructureStatic",
                        id = "#7",
                        name = "#7",
                        pos_x = 1,
                        pos_y = 2,
                        pos_z = 3,
                        rot_x = 4,
                        rot_y = 5,
                        rot_z = 6,
                        modelType = 22,
                        modelTypeText = "Immobilie",
                        tag = "alpha"
                    }, staticDto)
        assert.equals("ce.hub.StructureStatic", staticListRoom)
        assert.equals("id", staticListKeyId)
        assert.same({ {
                        ceType = "ce.hub.StructureStatic",
                        id = "#7",
                        name = "#7",
                        pos_x = 1,
                        pos_y = 2,
                        pos_z = 3,
                        rot_x = 4,
                        rot_y = 5,
                        rot_z = 6,
                        modelType = 22,
                        modelTypeText = "Immobilie",
                        tag = "alpha"
                    } }, staticDtos)

        assert.equals("ce.hub.StructureDynamic", dynamicCeType)
        assert.equals("id", dynamicKeyId)
        assert.equals("#7", dynamicKey)
        assert.same({
                        ceType = "ce.hub.StructureDynamic",
                        id = "#7",
                        light = true,
                        smoke = false,
                        fire = true
                    }, dynamicDto)
        assert.equals("ce.hub.StructureDynamic", dynamicListRoom)
        assert.equals("id", dynamicListKeyId)
        assert.same({ {
                        ceType = "ce.hub.StructureDynamic",
                        id = "#7",
                        light = true,
                        smoke = false,
                        fire = true
                    } }, dynamicDtos)
    end)
end)
