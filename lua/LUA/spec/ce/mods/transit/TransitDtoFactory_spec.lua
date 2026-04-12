insulate("ce.mods.transit.data.TransitDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.mods.transit.data.TransitDtoFactory")
    end)

    it("provides metadata for public transport DTO lists", function ()
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        local line = {
            id = "10",
            nr = "10",
            trafficType = "BUS",
            hidden = true,
            lineSegments = {
                {
                    id = "route-10",
                    destination = "Central",
                    routeName = "Route 10",
                    lineNr = "10",
                    hidden = true,
                    stations = {
                        {
                            station = { name = "Station A", hidden = true },
                            timeToStation = 3,
                            hidden = true
                        }
                    }
                }
            }
        }
        local ceType, keyId, key, lineDto = TransitDtoFactory.createLineDto(line)
        local stationCeType, stationKeyId, stationKey, stationDto =
            TransitDtoFactory.createStationDto({ name = "Station A" })
        local settingsCeType, settingsKeyId, settingsDtos =
            TransitDtoFactory.createModuleSettingDtoList({
                {
                    category = "Display",
                    name = "Next",
                    description = "Show next departures",
                    type = "boolean",
                    value = true,
                    eepFunction = "TransitSettings.setShowDepartureTippText",
                    hidden = true
                }
            })

        line.nr = "11"
        line.lineSegments[1].stations[1].station.name = "Changed"

        assert.equals("ce.mods.transit.Line", ceType)
        assert.equals("id", keyId)
        assert.equals("10", key)
        assert.same({
                        ceType = "ce.mods.transit.Line",
                        id = "10",
                        nr = "10",
                        trafficType = "BUS",
                        lineSegments = {
                            {
                                id = "route-10",
                                destination = "Central",
                                routeName = "Route 10",
                                lineNr = "10",
                                stations = {
                                    {
                                        station = { name = "Station A" },
                                        timeToStation = 3
                                    }
                                }
                            }
                        }
                    }, lineDto)
        assert.equals("ce.mods.transit.Station", stationCeType)
        assert.equals("id", stationKeyId)
        assert.equals("Station A", stationKey)
        assert.same({
                        ceType = "ce.mods.transit.Station",
                        id = "Station A",
                        name = "Station A",
                        platforms = {},  -- always policy, but no routePlatforms supplied
                        queue = {}       -- onselection, not selected
                    }, stationDto)
        assert.equals("ce.mods.transit.ModuleSetting", settingsCeType)
        assert.equals("name", settingsKeyId)
        assert.same({
                        {
                            ceType = "ce.mods.transit.ModuleSetting",
                            category = "Display",
                            name = "Next",
                            description = "Show next departures",
                            type = "boolean",
                            value = true,
                            eepFunction = "TransitSettings.setShowDepartureTippText"
                        }
                    }, settingsDtos)
    end)
end)
