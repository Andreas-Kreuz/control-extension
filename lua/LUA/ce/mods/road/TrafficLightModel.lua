if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLightModel ...") end

local SignalIndication = require("ce.mods.road.SignalIndication")
------------------------------------------------------------------------------------------
-- Klasse TrafficLightModel
-- Weiss, welche Signalstellung fuer rot, gelb und gruen geschaltet werden muessen.
------------------------------------------------------------------------------------------
local TrafficLightModel = {}
TrafficLightModel.allModels = {}

---
-- @param name Name des Ampeltyps
-- @param signalIndexRed Index der Signalstellung des roten Signals
-- @param signalIndexGreen Index der Signalstellung des gruenen Signals
-- @param signalIndexYellow Index der Signalstellung des gelben Signals
-- @param signalIndexRedYellow Index der Signalstellung des rot-gelben Signal (oder rot)
-- @param signalIndexPedestrian Index der Signalstellung in der die Fussgaenger gruen haben und die Autos rot
-- @param signalIndexSwitchOff Index der Signalstellung in der die Ampel komplett aus ist
-- @param signalIndexBlinkYellow Index der Signalstellung in der die Ampel gelb blinkt ohne den Verkehr zu beeinflussen
-- @param signalIndexGreenYellow Index der Signalstellung in der die Ampel grün und gelb zeigt
function TrafficLightModel:new(name, signalIndexRed, signalIndexGreen, signalIndexYellow, signalIndexRedYellow,
                               signalIndexPedestrian, signalIndexSwitchOff, signalIndexBlinkYellow,
                               signalIndexGreenYellow)
    assert(type(name) == "string", "Need 'name' as string")
    assert(type(signalIndexRed) == "number", "Need 'signalIndexRed' as number")
    assert(type(signalIndexGreen) == "number", "Need 'signalIndexGreen' as number")
    local o = {
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
    table.insert(TrafficLightModel.allModels, o)
    return x
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

-- Fuer die Strassenbahnsignale von MA1 - http://www.eep.euma.de/downloads/V80MA1F003.zip
-- 4er Signal, Stellung 2 als grün, z.B. Strab_Sig_09_LG auf gerade schalten
-- 4er Signal, Stellung 3 als grün, z.B. Strab_Sig_09_LG auf links schalten
-- 3er Signal, Stellung 3 als grün, z.B. Ak_Strab_Sig_05_gerade oder
--                                       Ak_Strab_Sig_05_gerade schalten
TrafficLightModel.MA1_STRAB_4er_2_gruen = TrafficLightModel:new("MA1_STRAB_4er_2_gruen", 1, 2, 4, 4)
TrafficLightModel.MA1_STRAB_4er_3_gruen = TrafficLightModel:new("MA1_STRAB_4er_3_gruen", 1, 3, 4, 4)
TrafficLightModel.MA1_STRAB_3er_2_gruen = TrafficLightModel:new("MA1_STRAB_3er_2_gruen", 1, 2, 3, 3)

-- Fuer die Ampeln von NP1 - http://eepshopping.de - Ampelset 1 und Ampelset 2
TrafficLightModel.NP1_3er_mit_FG = TrafficLightModel:new("Ampel_NP1_mit_FG", 2, 4, 5, 3, 1)
TrafficLightModel.NP1_3er_ohne_FG = TrafficLightModel:new("Ampel_NP1_ohne_FG", 1, 3, 4, 2)

-- Fuer die Ampeln von JS2 - http://eepshopping.de - Ampel-Baukasten (V80NJS20039)
-- Diese Signale sind teilweise mit und ohne Fussgaenger
TrafficLightModel.JS2_2er_nur_FG = TrafficLightModel:new("Ak_Ampel_2er_nur_FG", 1, 1, 1, 1, 2, 3, 3, 4)
TrafficLightModel.JS2_2er_gelb_gruen_aus = TrafficLightModel:new("Ampel_2er_Aus_Gelb-Grün", 1, 3, 5, 1, 1, 2, 6,
                                                                  4)
TrafficLightModel.JS2_2er_OFF_YELLOW_GREEN = TrafficLightModel.JS2_2er_gelb_gruen_aus
TrafficLightModel.JS2_2er_rot_gelb_aus = TrafficLightModel:new("Ampel_2er_Rot_Gelb_Aus", 1, 3, 2, 4, 1, 3,
                                                                5, 3)
TrafficLightModel.JS2_2er_rot_gruen = TrafficLightModel:new("Ampel_2er_Rot_Gruen", 1, 2, 1, 1, 1, 3, 3, 2)
TrafficLightModel.JS2_1er_gruen = TrafficLightModel:new("Ampel_1er_Gruen", 1, 2, 1, 1, 1, 1, 1, 2)
TrafficLightModel.JS2_3er_mit_FG = TrafficLightModel:new("Ampel_3er_XXX_mit_FG", 1, 3, 5, 2, 6, 7, 8, 4)
TrafficLightModel.JS2_3er_ohne_FG = TrafficLightModel:new("Ampel_3er_XXX_ohne_FG", 1, 3, 5, 2, 1, 6, 7, 4)

-- Unsichtbare Ampeln haben "nur" rot und gruen
TrafficLightModel.Unsichtbar_2er = TrafficLightModel:new("Unsichtbares Signal", 2, 1, 2, 2, 2, 1, 1)

-- No signal
TrafficLightModel.NONE = TrafficLightModel:new("NO SIGNAL MODEL", 1, 2, 3, 4, 5, 6, 7)

return TrafficLightModel
