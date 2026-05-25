if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.MODELV15NJS20220 ...") end
local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")

local function rollingStockFor(rollingStockName)
    return require("ce.hub.data.rollingstock.RollingStockRegistry").getOrCreate(rollingStockName)
end

local MODELV15NJS20220 = {}

local destinationTextureTexts = {
    [1] = "1.Fahrziel Vorn",
    [2] = "2.Fahrziel Vorn",
    [3] = "3.Fahrziel Vorn 1.Zeile",
    [4] = "3.Fahrziel Vorn 2.Zeile",
    [5] = "4.Fahrziel Vorn 1.Zeile",
    [6] = "4.Fahrziel Vorn 2.Zeile",
    [7] = "1.Fahrziel Seite 1.Zeile",
    [8] = "1.Fahrziel Seite 2.Zeile",
    [9] = "1.Fahrziel Seite 3.Zeile",
    [10] = "2.Fahrziel Seite 1.Zeile",
    [11] = "2.Fahrziel Seite 2.Zeile",
    [12] = "2.Fahrziel Seite 3.Zeile",
    [13] = "3.Fahrziel Seite 1.Zeile",
    [14] = "3.Fahrziel Seite 2.Zeile",
    [15] = "3.Fahrziel Seite 3.Zeile",
    [16] = "4.Fahrziel Seite 1.Zeile",
    [17] = "4.Fahrziel Seite 2.Zeile",
    [18] = "4.Fahrziel Seite 3.Zeile",
    [19] = "1.Liniennummer",
    [20] = "2.Liniennummer",
    [21] = "3.Liniennummer",
    [22] = "4.Liniennummer",
    [23] = "Wagennummer Front",
    [24] = "Wagennummer Seite",
    [25] = "Verkehrsgesellschaft"
}

local function formatLineTextureText(line)
    return "  " .. line .. "  "
end

local function createWagen(axisNames, textureTexts, hasDoors, hasTextureTexts)
    local wagen = RollingStockModel:new({
        axisNames = axisNames,
        textureTexts = textureTexts
    })

    function wagen:setLine(rollingStockName, line)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(line) == "string", "Need 'line' as string")
        if hasTextureTexts then
            rollingStockFor(rollingStockName):setTextureText(22, formatLineTextureText(line))
        end
    end

    function wagen:setDestination(rollingStockName, destination)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(destination) == "string", "Need 'destination' as string")
        if hasTextureTexts then
            rollingStockFor(rollingStockName):setAxis("Linie Fahrziel", 100)
            rollingStockFor(rollingStockName):setTextureText(5, destination)
            rollingStockFor(rollingStockName):setTextureText(6, "")
            rollingStockFor(rollingStockName):setTextureText(18, destination)
        end
    end

    function wagen:setOrigin(rollingStockName, origin)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(origin) == "string", "Need 'origin' as string")
        if hasTextureTexts then
            rollingStockFor(rollingStockName):setTextureText(16, origin)
        end
    end

    function wagen:setNextStop(rollingStockName, nextStop)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(nextStop) == "string", "Need 'nextStop' as string")
        if hasTextureTexts then
            rollingStockFor(rollingStockName):setTextureText(6, nextStop)
            rollingStockFor(rollingStockName):setTextureText(17, nextStop)
        end
    end

    function wagen:setStations(rollingStockName, stations)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(stations) == "string", "Need 'stations' as string")
    end

    function wagen:setWagonNumber(rollingStockName, nr)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        assert(type(nr) == "string", "Need 'nr' as string")
        if hasTextureTexts then
            rollingStockFor(rollingStockName):setTextureText(23, nr)
            rollingStockFor(rollingStockName):setTextureText(24, nr)
        end
    end

    function wagen:openDoors(rollingStockName)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        if hasDoors then
            rollingStockFor(rollingStockName):setAxis("TuerRechts", 100)
        end
    end

    function wagen:closeDoors(rollingStockName)
        assert(type(self) == "table", "Call this method with ':'")
        assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
        if hasDoors then
            rollingStockFor(rollingStockName):setAxis("TuerRechts", 0)
        end
    end

    return wagen
end

local GT6_8_7ND_Wagen1 = createWagen({
                                         "Linie Fahrziel",
                                         "Fahrer",
                                         "Fahrgast",
                                         "TuerRechts",
                                         "TuerFahrer",
                                         "Kupplung"
                                     }, destinationTextureTexts, true, true)

local GT6_8_7ND_Wagen2 = createWagen({
                                         "Linie Fahrziel",
                                         "Fahrgast",
                                         "TuerRechts"
                                     }, destinationTextureTexts, true, true)

local GT6_8_7ND_Wagen3 = createWagen({
                                         "Fahrgast",
                                         "0m =Strom= 5m ==== 6m ="
                                     }, {}, false, false)

local GT6_8_7ND_Wagen4 = createWagen({
                                         "Fahrgast",
                                         "TuerRechts"
                                     }, {}, true, false)

local GT6_8_7ND_Wagen5 = createWagen({
                                         "Fahrgast"
                                     }, {}, false, false)

MODELV15NJS20220["GT6_8_7NDWagen1A_JS2"] = GT6_8_7ND_Wagen1
MODELV15NJS20220["GT6_8_7NDWagen1B_JS2"] = GT6_8_7ND_Wagen1
MODELV15NJS20220["GT6_8_7NDWagen2A_JS2"] = GT6_8_7ND_Wagen2
MODELV15NJS20220["GT6_8_7NDWagen2B_JS2"] = GT6_8_7ND_Wagen2
MODELV15NJS20220["GT6_8_7NDWagen3_JS2"] = GT6_8_7ND_Wagen3
MODELV15NJS20220["GT6_8_7NDWagen4_JS2"] = GT6_8_7ND_Wagen4
MODELV15NJS20220["GT6_8_7NDWagen5_JS2"] = GT6_8_7ND_Wagen5

function MODELV15NJS20220.register(registry)
    registry.addModel(
        "GT6_8_7NDWagen1A_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN1_JS2.3dm",
        GT6_8_7ND_Wagen1
    )
    registry.addModel(
        "GT6_8_7NDWagen1B_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN1B_JS2.3dm",
        GT6_8_7ND_Wagen1
    )
    registry.addModel(
        "GT6_8_7NDWagen2A_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN2_JS2.3dm",
        GT6_8_7ND_Wagen2
    )
    registry.addModel(
        "GT6_8_7NDWagen2B_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN2B_JS2.3dm",
        GT6_8_7ND_Wagen2
    )
    registry.addModel(
        "GT6_8_7NDWagen3_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN3_JS2.3dm",
        GT6_8_7ND_Wagen3
    )
    registry.addModel(
        "GT6_8_7NDWagen4_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN4_JS2.3dm",
        GT6_8_7ND_Wagen4
    )
    registry.addModel(
        "GT6_8_7NDWagen5_JS2",
        "SCHIENE\\STRASSENBAHN\\GT6_8_7NDWAGEN5_JS2.3dm",
        GT6_8_7ND_Wagen5
    )
end

return MODELV15NJS20220
