if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.ModelV15NMA10013 ...") end
local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")

local function rollingStockFor(rollingStockName)
    return require("ce.hub.data.rollingstock.RollingStockRegistry").getOrCreate(rollingStockName)
end

local ModelV15NMA10013 = {}
local nextStopPrefix = "Nächster Halt: "
local gtADisplayState = {}

local function gtAStateFor(rollingStockName)
    gtADisplayState[rollingStockName] = gtADisplayState[rollingStockName] or {
        origin = "",
        nextStop = "",
        destination = ""
    }
    return gtADisplayState[rollingStockName]
end

local function updateGtADestinationList(rollingStockName)
    local state = gtAStateFor(rollingStockName)
    rollingStockFor(rollingStockName):setTextureText(3,
                                                                       state.origin .. "\n" ..
                                                                       nextStopPrefix .. state.nextStop .. "\n" ..
                                                                       state.destination)
end

local GT_A = RollingStockModel:new({
    axisNames = {
        "Kupplung Kontakte Abdeckung",
        "Kupplung Wetterschutz",
        "Stromabnehmer",
        "Scheibenwischer",
        "Fahrgäste",
        "Türwarnlicht",
        "Türöffner Licht",
        "Fahrer",
        "Türen vorn",
        "Türen Mitte"
    },
    textureTexts = {
        [1] = "Liniennummer",
        [2] = "Fahrtziel vorn",
        [3] = "Fahrtziele links",
        [4] = "Linienkurstafel",
        [5] = "Fahrzeugnummer außen rechts",
        [6] = "Fahrzeugnummer außen links",
        [7] = "Fahrzeugnummer innen",
        [8] = "Fahrzeugnummer Fahrpult"
    }
})

function GT_A:setLine(rollingStockName, line)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(line) == "string", "Need 'line' as string")
    rollingStockFor(rollingStockName):setTextureText(1, line)
    rollingStockFor(rollingStockName):setTextureText(4, line .. " - 01")
end

function GT_A:setDestination(rollingStockName, destination)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(destination) == "string", "Need 'destination' as string")
    rollingStockFor(rollingStockName):setTextureText(2, destination)
    gtAStateFor(rollingStockName).destination = destination
    updateGtADestinationList(rollingStockName)
end

function GT_A:setOrigin(rollingStockName, origin)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(origin) == "string", "Need 'origin' as string")
    gtAStateFor(rollingStockName).origin = origin
    updateGtADestinationList(rollingStockName)
end

function GT_A:setNextStop(rollingStockName, nextStop)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(nextStop) == "string", "Need 'nextStop' as string")
    gtAStateFor(rollingStockName).nextStop = nextStop
    updateGtADestinationList(rollingStockName)
end

function GT_A:setStations(rollingStockName, stations)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(stations) == "string", "Need 'stations' as string")
end

function GT_A:setWagonNumber(rollingStockName, nr)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setTextureText(5, nr)
    rollingStockFor(rollingStockName):setTextureText(6, nr)
    rollingStockFor(rollingStockName):setTextureText(7, nr)
    rollingStockFor(rollingStockName):setTextureText(8, nr)
end

function GT_A:openDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setAxis("Türen Mitte", 100)
    rollingStockFor(rollingStockName):setAxis("Türen vorn", 100)
end

function GT_A:closeDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setAxis("Türen Mitte", 0)
    rollingStockFor(rollingStockName):setAxis("Türen vorn", 0)
end

ModelV15NMA10013["GT4 Serie 2 (1) Wagen A"] = GT_A
ModelV15NMA10013["GT4 Serie 2 (2) Wagen A"] = GT_A

local GT_B = RollingStockModel:new({
    axisNames = {
        "Kupplung Kontakte Abdeckung",
        "Kupplung Wetterschutz",
        "Fahrgäste",
        "Türöffner Licht",
        "Türwarnlicht",
        "Fahrer",
        "Türen hinten"
    },
    textureTexts = {
        [1] = "Liniennummer",
        [2] = "Fahrtziele links",
        [3] = "Fahrzeugnummer außen",
        [4] = "Fahrzeugnummer innen"
    }
})

function GT_B:setLine(rollingStockName, line)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setTextureText(1, line)
end

function GT_B:setDestination(rollingStockName, destination)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(destination) == "string", "Need 'destination' as string")
end

function GT_B:setStations(rollingStockName, stations)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setTextureText(2, stations)
end

function GT_B:setWagonNumber(rollingStockName, nr)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setTextureText(3, nr)
    rollingStockFor(rollingStockName):setTextureText(4, nr)
end

function GT_B:openDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setAxis("Türen hinten", 100)
end

function GT_B:closeDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    rollingStockFor(rollingStockName):setAxis("Türen hinten", 0)
end

ModelV15NMA10013["GT4 Serie 2 (1) Wagen B"] = GT_B
ModelV15NMA10013["GT4 Serie 2 (2) Wagen B"] = GT_B

function ModelV15NMA10013.register(registry)
    registry.addModel("GT4 Serie 2 (1) Wagen A", "SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_MA1.3dm", GT_A)
    registry.addModel("GT4 Serie 2 (1) Wagen B", "SCHIENE\\STRASSENBAHN\\GT4_WG_B_01_MA1.3dm", GT_B)
    registry.addModel("GT4 Serie 2 (2) Wagen A", "SCHIENE\\STRASSENBAHN\\GT4_WG_A_02_MA1.3dm", GT_A)
    registry.addModel("GT4 Serie 2 (2) Wagen B", "SCHIENE\\STRASSENBAHN\\GT4_WG_B_02_MA1.3dm", GT_B)
    registry.addModel("GT4 Serie 2 Wagen A LGK MA1", "SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_W_02_MA1.3dm", GT_A)
    registry.addModel("GT4 Serie 2 Wagen B LGK MA1", "SCHIENE\\STRASSENBAHN\\GT4_WG_B_01_W_02_MA1.3dm", GT_B)
    registry.addModel("GT4 Serie 2 Wagen A Vaillant MA1", "SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_W_01_MA1.3dm", GT_A)
    registry.addModel("GT4 Serie 2 Wagen B Vaillant MA1", "SCHIENE\\STRASSENBAHN\\GT4_WG_B_01_W_01_MA1.3dm", GT_B)
end

return ModelV15NMA10013
