insulate("ce.mods.transit.CeTransitModule", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.transit.CeTransitModule")
        clearModule("ce.mods.transit.options.TransitOptionsRegistry")
        clearModule("ce.mods.transit.data.TransitDtoFactory")
    end)

    local function makeStation(name, queueEntries, routePlatforms)
        return {
            name = name,
            routePlatforms = routePlatforms or {},
            queue = {
                getTrainEntries = function () return queueEntries or {} end
            }
        }
    end

    it("returns the module from setOptions for chaining", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        assert.equals(CeTransitModule, CeTransitModule.setOptions({}))
    end)

    it("station DTO: platforms always present, queue absent when not selected (default options)", function ()
        require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, { Route10 = { platform = 2 } })

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, false)

        assert.same({ { nr = 2, routes = { "Route10" } } }, dto.platforms) -- "always" -> populated
        assert.same({}, dto.queue)                                         -- "onselection", not selected -> empty
    end)

    it("station DTO: queue present when selected (default options)", function ()
        require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, {})

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, true)

        -- "onselection" + selected -> populated
        assert.same({
                        { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
                    }, dto.queue)
    end)

    it("station DTO: queue present when not selected after setOptions with queue always", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { queue = "always" }
                }
            }
        })

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, {})

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, false)

        assert.same({
                        { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
                    }, dto.queue)
    end)

    it("station DTO: platforms absent even when selected after setOptions with platforms never", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { platforms = "never" }
                }
            }
        })

        local station = makeStation("Station A", {}, { Route10 = { platform = 2 } })

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, true)

        assert.same({}, dto.platforms)
    end)

    it("setOptions deep-merges: unspecified ceTypes retain their defaults", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { queue = "always" }
                }
            }
        })

        local line = { id = "10", nr = "10", trafficType = "BUS", lineSegments = {} }
        local _, _, _, dto = TransitDtoFactory.createLineDto(line)

        assert.equals("10", dto.nr)
        assert.equals("BUS", dto.trafficType)
        assert.same({}, dto.lineSegments)
    end)
end)
