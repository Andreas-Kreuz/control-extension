insulate("ce.mods.road.CeRoadModule", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.CeRoadModule")
        clearModule("ce.mods.road.options.RoadOptionsRegistry")
        clearModule("ce.mods.road.data.RoadDtoFactory")
    end)

    local intersection = {
        id = 1,
        name = "A",
        currentPhase = "P1",
        manualPhase = "P2",
        nextPhase = "P3",
        ready = true,
        greenTimeSeconds = 15,
        staticCams = { "Cam 1" },
        phases = {
            {
                id = "A-P1",
                name = "P1",
                order = 1,
                prio = 1,
                greenTimeSeconds = 15,
                signalHeads = { { signalId = 1, type = "CAR" } }
            }
        }
    }

    it("returns the module from setOptions for chaining", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        assert.equals(CeRoadModule, CeRoadModule.setOptions({}))
    end)

    it("intersection DTO: always fields are populated, oninterest fields are empty by default", function ()
        -- Road factory hardcodes isSelected=false, so oninterest fields never appear in default state
        require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        local _, _, _, dto = RoadDtoFactory.createIntersectionDto(intersection)

        assert.equals("A", dto.name)             -- "always" by default -> populated
        assert.equals("", dto.manualPhase)   -- "oninterest" by default, never selected -> empty
        assert.equals("", dto.currentPhase)  -- "oninterest" by default, never selected -> empty
        assert.equals("", dto.nextPhase)     -- "oninterest" by default, never selected -> empty
        assert.is_false(dto.ready)               -- "oninterest" by default, never selected -> false
        assert.equals(15, dto.greenTimeSeconds)      -- "always" by default -> populated
        assert.same({ "Cam 1" }, dto.staticCams) -- "always" by default -> populated
        assert.same(intersection.phases, dto.phases)
    end)

    it("intersection DTO: oninterest fields are populated after setOptions with always", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        CeRoadModule.setOptions({
            ceTypes = {
                intersections = {
                    fieldPublish = {
                        currentPhase = "always",
                        manualPhase = "always",
                        nextPhase = "always",
                        ready = "always"
                    }
                }
            }
        })

        local _, _, _, dto = RoadDtoFactory.createIntersectionDto(intersection)

        assert.equals("P1", dto.currentPhase)
        assert.equals("P3", dto.nextPhase)
        assert.is_true(dto.ready)
        assert.equals(15, dto.greenTimeSeconds)
        assert.same({ "Cam 1" }, dto.staticCams)
        assert.equals("A", dto.name) -- unspecified "always" field stays
        assert.equals("P2", dto.manualPhase)
    end)

    it("intersection DTO: always fields become empty after setOptions with never", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        CeRoadModule.setOptions({
            ceTypes = {
                intersections = {
                    fieldPublish = { name = "never", manualPhase = "never" }
                }
            }
        })

        local _, _, _, dto = RoadDtoFactory.createIntersectionDto(intersection)

        assert.equals("", dto.name)
        assert.equals("", dto.manualPhase)
    end)

    it("setOptions deep-merges: unspecified ceTypes retain their defaults", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        CeRoadModule.setOptions({
            ceTypes = {
                intersections = {
                    fieldPublish = { currentPhase = "always" }
                }
            }
        })

        local phase = { id = "A-P1", intersectionId = "A", name = "P1", prio = 1 }
        local _, _, _, dto = RoadDtoFactory.createIntersectionPhaseDto(phase)

        assert.equals("A", dto.intersectionId)
        assert.equals("P1", dto.name)
        assert.equals(1, dto.prio)
    end)
end)
