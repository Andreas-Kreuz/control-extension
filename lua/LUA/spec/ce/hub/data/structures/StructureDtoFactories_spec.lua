insulate("ce.hub.data.structures.StructureDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.structures.StructureDtoFactory")
    end)

    it("creates a unified full DTO with all fields", function ()
        local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
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
            fire = true,
            getTag = function(self) return self.tag end,
            getLight = function(self) return self.light end,
            getSmoke = function(self) return self.smoke end,
            getFire = function(self) return self.fire end
        }

        local ceType, keyId, key, dto = StructureDtoFactory.createFullDto(structure)

        assert.equals("ce.hub.Structure", ceType)
        assert.equals("id", keyId)
        assert.equals("#7", key)
        assert.same({
                        ceType = "ce.hub.Structure",
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
                    }, dto)
    end)

    it("creates a patch DTO with only dirty fields", function ()
        local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
        local structure = {
            id = "#7",
            name = "#7",
            tag = "changed",
            fire = true,
            getTag = function(self) return self.tag end,
            getLight = function() return false end,
            getSmoke = function() return false end,
            getFire = function(self) return self.fire end
        }

        local ceType, keyId, key, dto = StructureDtoFactory.createPatchDto(structure, { tag = true, fire = true })

        assert.equals("ce.hub.Structure", ceType)
        assert.equals("id", keyId)
        assert.equals("#7", key)
        assert.same({
                        ceType = "ce.hub.Structure",
                        id = "#7",
                        tag = "changed",
                        fire = true
                    }, dto)
    end)
end)
