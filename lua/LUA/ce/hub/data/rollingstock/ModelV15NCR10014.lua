if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.ModelV15NCR10014 ...") end
local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")

local ModelV15NCR10014 = {}

local citybusTexturesGelb = {
    [1] = "Nummernschild",
    [2] = "Verkehrsunternehmen schwarz",
    [3] = "Verkehrsunternehmen gelb",
    [4] = "Linie",
    [5] = "Fahrziel"
}

local citybusTexturesRot = {
    [1] = "Nummernschild",
    [2] = "Verkehrsunternehmen schwarz",
    [3] = "Verkehrsunternehmen rot",
    [4] = "Linie",
    [5] = "Fahrziel"
}

local function formatLicencePlateTextureText(licencePlate)
    local cityCode, registration = licencePlate:gsub("%-", " "):match("^%s*(%S+)%s+(.+)%s*$")
    if cityCode then
        registration = registration:gsub("%s+", " ")
        local letters, digits = registration:match("^([A-Z]+)%s*(%d+)$")
        if letters then registration = letters .. " " .. digits end
        return "  " .. cityCode .. "       " .. registration
    end
    return licencePlate
end

local function createCitybus(axisNames, textureTexts, doorAxisNames)
    local citybus = RollingStockModel:new({
        axisNames = axisNames,
        textureTexts = textureTexts
    })

    function citybus:setLine(rollingStockName, line)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(line) == "string", "Need 'line' as string")
        EEPRollingstockSetTextureText(rollingStockName, 4, line)
    end

    function citybus:setDestination(rollingStockName, destination)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(destination) == "string", "Need 'destination' as string")
        EEPRollingstockSetTextureText(rollingStockName, 5, destination)
    end

    function citybus:setOrigin(rollingStockName, origin)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(origin) == "string", "Need 'origin' as string")
    end

    function citybus:setNextStop(rollingStockName, nextStop)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(nextStop) == "string", "Need 'nextStop' as string")
    end

    function citybus:setStations(rollingStockName, stations)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(stations) == "string", "Need 'stations' as string")
    end

    function citybus:setLicencePlate(rollingStockName, licencePlate)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(licencePlate) == "string", "Need 'licencePlate' as string")
        EEPRollingstockSetTextureText(rollingStockName, 1, formatLicencePlateTextureText(licencePlate))
    end

    function citybus:setWagonNumber(rollingStockName, wagonNumber)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(wagonNumber) == "string", "Need 'wagonNumber' as string")
        EEPRollingstockSetTextureText(rollingStockName, 2, wagonNumber)
    end

    function citybus:openDoors(rollingStockName)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        for _, axisName in ipairs(doorAxisNames) do
            EEPRollingstockSetAxis(rollingStockName, axisName, 100)
        end
    end

    function citybus:closeDoors(rollingStockName)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        for _, axisName in ipairs(doorAxisNames) do
            EEPRollingstockSetAxis(rollingStockName, axisName, 0)
        end
    end

    return citybus
end

local Citybus1GLFL = createCitybus({
                                       "Passagiere",
                                       "Fahrer",
                                       "Tuer1",
                                       "Tuer2"
                                   }, citybusTexturesGelb, {
                                       "Tuer1",
                                       "Tuer2"
                                   })

local Citybus1GLA = createCitybus({
                                      "Passagiere",
                                      "Tuer3",
                                      "Tuer4"
                                  }, citybusTexturesGelb, {
                                      "Tuer3",
                                      "Tuer4"
                                  })

local CitybusFL = createCitybus({
                                    "Passagiere",
                                    "Fahrer",
                                    "Tuer1",
                                    "Tuer2",
                                    "Tuer3"
                                }, citybusTexturesRot, {
                                    "Tuer1",
                                    "Tuer2",
                                    "Tuer3"
                                })

ModelV15NCR10014["MAN Citybus 1 GL FL gelb CR1"] = Citybus1GLFL
ModelV15NCR10014["MAN Citybus 1 GLA gelb CR1"] = Citybus1GLA
ModelV15NCR10014["MAN Citybus FL gelb CR1"] = CitybusFL
ModelV15NCR10014["MAN Citybus gelb CR1"] = CitybusFL
ModelV15NCR10014["MAN Citybus 1 GL gelb CR1"] = Citybus1GLFL

function ModelV15NCR10014.register(registry)
    registry.addModel(
        "MAN Citybus 1 GL FL gelb CR1",
        "STRASSE\\BUS\\MAN_CITYBUS_1_GELB_GLFL_CR1.3dm",
        Citybus1GLFL
    )
    registry.addModel(
        "MAN Citybus 1 GLA gelb CR1",
        "STRASSE\\BUS\\MAN_CITYBUS_1_GELB_GLA_CR1.3dm",
        Citybus1GLA
    )
    registry.addModel(
        "MAN Citybus FL gelb CR1",
        "STRASSE\\BUS\\MAN_CITYBUS_GELB_FL_CR1.3dm",
        CitybusFL
    )
    registry.addModel(
        "MAN Citybus gelb CR1",
        "STRASSE\\BUS\\MAN_CITYBUS_GELB_CR1.3dm",
        CitybusFL
    )
    registry.addModel(
        "MAN Citybus 1 GL gelb CR1",
        "STRASSE\\BUS\\MAN_CITYBUS_1_GELB_GL_CR1.3dm",
        Citybus1GLFL
    )
end

return ModelV15NCR10014
