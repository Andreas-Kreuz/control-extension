if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLightModel ...") end

local SignalIndication = require("ce.mods.road.SignalIndication")
------------------------------------------------------------------------------------------
-- Klasse TrafficLightModel
-- Weiss, welche Signalstellung fuer rot, gelb und gruen geschaltet werden muessen.
------------------------------------------------------------------------------------------
local TrafficLightModel = {}
TrafficLightModel.allModels = {}

---
-- @param id Lua-Konstantenname des Ampeltyps (z.B. "JS2_3er_mit_FG")
-- @param name Anzeigename des Ampeltyps
-- @param signalIndexRed Index der Signalstellung des roten Signals
-- @param signalIndexGreen Index der Signalstellung des gruenen Signals
-- @param signalIndexYellow Index der Signalstellung des gelben Signals
-- @param signalIndexRedYellow Index der Signalstellung des rot-gelben Signal (oder rot)
-- @param signalIndexPedestrian Index der Signalstellung in der die Fussgaenger gruen haben und die Autos rot
-- @param signalIndexSwitchOff Index der Signalstellung in der die Ampel komplett aus ist
-- @param signalIndexBlinkYellow Index der Signalstellung in der die Ampel gelb blinkt ohne den Verkehr zu beeinflussen
-- @param signalIndexGreenYellow Index der Signalstellung in der die Ampel gruen und gelb zeigt
function TrafficLightModel:new(id, name, signalIndexRed, signalIndexGreen, signalIndexYellow, signalIndexRedYellow,
                               signalIndexPedestrian, signalIndexSwitchOff, signalIndexBlinkYellow,
                               signalIndexGreenYellow)
    assert(type(id) == "string", "Need 'id' as string")
    assert(type(name) == "string", "Need 'name' as string")
    assert(type(signalIndexRed) == "number", "Need 'signalIndexRed' as number")
    assert(type(signalIndexGreen) == "number", "Need 'signalIndexGreen' as number")
    local o = {
        id = id,
        name = name,
        signalIndexRed = signalIndexRed,
        signalIndexGreen = signalIndexGreen,
        signalIndexYellow = signalIndexYellow or signalIndexRed,
        signalIndexRedYellow = signalIndexRedYellow or signalIndexRed,
        signalIndexPedestrian = signalIndexPedestrian,
        signalIndexSwitchOff = signalIndexSwitchOff or signalIndexGreen,
        signalIndexBlinkYellow = signalIndexBlinkYellow or signalIndexSwitchOff,
        signalIndexGreenYellow = signalIndexGreenYellow or signalIndexGreen
    }
    self.__index = self
    local x = setmetatable(o, self)
    TrafficLightModel.allModels[id] = o
    return x
end

function TrafficLightModel.resolve(id)
    return TrafficLightModel.allModels[id]
end

local function basename(value)
    return string.match(value:gsub("\\", "/"), "([^/]+)$") or value
end

local function withoutExtension(value)
    return string.gsub(value, "%.[^.]+$", "")
end

function TrafficLightModel.inferFromItemName(itemNameWithModelPath)
    if not itemNameWithModelPath then return nil end
    local normalizedPath = itemNameWithModelPath:gsub("\\", "/")
    local normalizedPathLower = string.lower(normalizedPath)
    if normalizedPathLower == "signale/signale/signal_unsichtbar.3dm" then
        return TrafficLightModel.Unsichtbar_2er
    end

    local fileName = basename(normalizedPath)
    local normalizedFileName = string.lower(fileName)
    local normalizedFileNameWithoutExtension = string.lower(withoutExtension(fileName))
    if string.match(normalizedFileName, "^3er") and string.match(normalizedFileName, "_js2%.3dm$") then
        return string.find(normalizedFileName, "fg") and TrafficLightModel.JS2_3er_mit_FG or
            TrafficLightModel.JS2_3er_ohne_FG
    end
    if string.match(normalizedFileName, "^2er") and string.match(normalizedFileName, "_js2%.3dm$") then
        if string.find(normalizedFileName, "fg") then return TrafficLightModel.JS2_2er_nur_FG end
        if string.find(normalizedFileName, "gruengelb") then return TrafficLightModel.JS2_2er_gelb_gruen_aus end
        if string.find(normalizedFileName, "rotgelb") then return TrafficLightModel.JS2_2er_rot_gelb_aus end
        if string.find(normalizedFileName, "rotgruen") then return TrafficLightModel.JS2_2er_rot_gruen end
    end
    if normalizedFileNameWithoutExtension == "1erlinksmast_js2" then return TrafficLightModel.JS2_1er_gruen end
    if string.match(normalizedFileNameWithoutExtension, "_np1$") then
        if string.find(normalizedFileNameWithoutExtension, "fd") or
            string.find(normalizedFileNameWithoutExtension, "fe") then
            return TrafficLightModel.NP1_3er_mit_FG
        end
        if string.find(normalizedFileNameWithoutExtension, "of") then return TrafficLightModel.NP1_3er_ohne_FG end
    end
    return nil
end

function TrafficLightModel:print() print(self.name) end

function TrafficLightModel:signalIndexOf(indication)
    assert(type(indication) == "string", "Need 'indication' as string")
    if indication == SignalIndication.RED then
        return self.signalIndexRed
    elseif indication == SignalIndication.GREEN then
        return self.signalIndexGreen
    elseif indication == SignalIndication.YELLOW then
        return self.signalIndexYellow
    elseif indication == SignalIndication.REDYELLOW then
        return self.signalIndexRedYellow
    elseif indication == SignalIndication.GREENYELLOW then
        return self.signalIndexGreenYellow
    elseif indication == SignalIndication.PEDESTRIAN then
        return self.signalIndexPedestrian
    elseif indication == SignalIndication.OFF then
        return self.signalIndexSwitchOff
    elseif indication == SignalIndication.OFF_BLINKING then
        return self.signalIndexBlinkYellow
    else
        assert(false, "Unknown indication " .. indication)
    end
end

function TrafficLightModel:indicationOf(signalIndex)
    assert(type(signalIndex) == "number", "Need 'signalIndex' as number")
    if signalIndex == self.signalIndexRed then
        return SignalIndication.RED
    elseif signalIndex == self.signalIndexGreen then
        return SignalIndication.GREEN
    elseif signalIndex == self.signalIndexGreenYellow then
        return SignalIndication.GREENYELLOW
    elseif signalIndex == self.signalIndexYellow then
        return SignalIndication.YELLOW
    elseif signalIndex == self.signalIndexRedYellow then
        return SignalIndication.REDYELLOW
    elseif signalIndex == self.signalIndexPedestrian then
        return SignalIndication.PEDESTRIAN
    elseif signalIndex == self.signalIndexBlinkYellow then
        return SignalIndication.OFF_BLINKING
    elseif signalIndex == self.signalIndexSwitchOff then
        return SignalIndication.OFF
    else
        return SignalIndication.UNKNOWN
    end
end

---------------------
-- Ampeln und Signale
---------------------
local TLM                    = TrafficLightModel

-- Fuer die Strassenbahnsignale von MA1 - http://www.eep.euma.de/downloads/V80MA1F003.zip
TLM.MA1_STRAB_4er_2_gruen    = TLM:new("MA1_STRAB_4er_2_gruen", "MA1 STRAB 4er-Ampel (Stellung 2=grün)", 1, 2, 4, 4)
TLM.MA1_STRAB_4er_3_gruen    = TLM:new("MA1_STRAB_4er_3_gruen", "MA1 STRAB 4er-Ampel (Stellung 3=grün)", 1, 3, 4, 4)
TLM.MA1_STRAB_3er_2_gruen    = TLM:new("MA1_STRAB_3er_2_gruen", "MA1 STRAB 3er-Ampel (Stellung 2=grün)", 1, 2, 3, 3)

-- Fuer die Ampeln von NP1 - http://eepshopping.de - Ampelset 1 und Ampelset 2
TLM.NP1_3er_mit_FG           = TLM:new("NP1_3er_mit_FG", "NP1 3er-Ampel mit Fußgängern", 2, 4, 5, 3, 1)
TLM.NP1_3er_ohne_FG          = TLM:new("NP1_3er_ohne_FG", "NP1 3er-Ampel ohne Fußgänger", 1, 3, 4, 2)

-- Fuer die Ampeln von JS2 - http://eepshopping.de - Ampel-Baukasten (V80NJS20039)
TLM.JS2_2er_nur_FG           = TLM:new("JS2_2er_nur_FG", "JS2 2er-Ampel (nur Fußgänger)", 1, 1, 1, 1, 2, 3, 3, 4)
TLM.JS2_2er_gelb_gruen_aus   = TLM:new("JS2_2er_gelb_gruen_aus", "JS2 2er-Ampel (gelb/grün)", 1, 3, 5, 1, 1, 2, 6, 4)
TLM.JS2_2er_OFF_YELLOW_GREEN = TLM.JS2_2er_gelb_gruen_aus
TLM.JS2_2er_rot_gelb_aus     = TLM:new("JS2_2er_rot_gelb_aus", "JS2 2er-Ampel (rot/gelb/aus)", 1, 3, 2, 4, 1, 3, 5, 3)
TLM.JS2_2er_rot_gruen        = TLM:new("JS2_2er_rot_gruen", "JS2 2er-Ampel (rot/grün)", 1, 2, 1, 1, 1, 3, 3, 2)
TLM.JS2_1er_gruen            = TLM:new("JS2_1er_gruen", "JS2 1er-Ampel (grün)", 1, 2, 1, 1, 1, 1, 1, 2)
TLM.JS2_3er_mit_FG           = TLM:new("JS2_3er_mit_FG", "JS2 3er-Ampel mit Fußgängern", 1, 3, 5, 2, 6, 7, 8, 4)
TLM.JS2_3er_ohne_FG          = TLM:new("JS2_3er_ohne_FG", "JS2 3er-Ampel ohne Fußgänger", 1, 3, 5, 2, 1, 6, 7, 4)

-- Unsichtbare Ampeln haben "nur" rot und gruen
TLM.Unsichtbar_2er           = TLM:new("Unsichtbar_2er", "Unsichtbares Signal", 2, 1, 2, 2, 2, 1, 1)

-- Kein Signal
TLM.NONE                     = TLM:new("NONE", "NO SIGNAL MODEL", 1, 2, 3, 4, 5, 6, 7)

return TrafficLightModel
