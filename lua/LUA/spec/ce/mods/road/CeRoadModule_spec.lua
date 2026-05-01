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
        currentSwitching = "S1",
        manualSwitching = "S2",
        nextSwitching = "S3",
        ready = true,
        timeForGreen = 15,
        staticCams = { "Cam 1" },
        phases = {
            {
                id = "A-S1",
                name = "S1",
                order = 1,
                prio = 1,
                greenPhaseSeconds = 15,
                trafficLights = { { signalId = 1, type = "CAR" } }
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
        assert.equals("", dto.manualSwitching)   -- "oninterest" by default, never selected -> empty
        assert.equals("", dto.currentSwitching)  -- "oninterest" by default, never selected -> empty
        assert.equals("", dto.nextSwitching)     -- "oninterest" by default, never selected -> empty
        assert.is_false(dto.ready)               -- "oninterest" by default, never selected -> false
        assert.equals(15, dto.timeForGreen)      -- "always" by default -> populated
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
                        currentSwitching = "always",
                        manualSwitching = "always",
                        nextSwitching = "always",
                        ready = "always"
                    }
                }
            }
        })

        local _, _, _, dto = RoadDtoFactory.createIntersectionDto(intersection)

        assert.equals("S1", dto.currentSwitching)
        assert.equals("S3", dto.nextSwitching)
        assert.is_true(dto.ready)
        assert.equals(15, dto.timeForGreen)
        assert.same({ "Cam 1" }, dto.staticCams)
        assert.equals("A", dto.name) -- unspecified "always" field stays
        assert.equals("S2", dto.manualSwitching)
    end)

    it("intersection DTO: always fields become empty after setOptions with never", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        CeRoadModule.setOptions({
            ceTypes = {
                intersections = {
                    fieldPublish = { name = "never", manualSwitching = "never" }
                }
            }
        })

        local _, _, _, dto = RoadDtoFactory.createIntersectionDto(intersection)

        assert.equals("", dto.name)
        assert.equals("", dto.manualSwitching)
    end)

    it("setOptions deep-merges: unspecified ceTypes retain their defaults", function ()
        local CeRoadModule = require("ce.mods.road.CeRoadModule")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        CeRoadModule.setOptions({
            ceTypes = {
                intersections = {
                    fieldPublish = { currentSwitching = "always" }
                }
            }
        })

        local switching = { id = "A-S1", intersectionId = "A", name = "S1", prio = 1 }
        local _, _, _, dto = RoadDtoFactory.createIntersectionSwitchingDto(switching)

        assert.equals("A", dto.intersectionId)
        assert.equals("S1", dto.name)
        assert.equals(1, dto.prio)
    end)
end)
