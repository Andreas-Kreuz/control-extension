if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLightModel ...") end

local SignalIndication = require("ce.mods.road.SignalIndication")
------------------------------------------------------------------------------------------
-- Klasse TrafficLightModel
-- Weiss, welche Signalstellung fuer rot, gelb und gruen geschaltet werden muessen.
------------------------------------------------------------------------------------------
local TrafficLightModel = {}
TrafficLightModel.allModels = {}
local allModelsOrdered = {}

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
    table.insert(allModelsOrdered, o)
    o.modelNameMatchOrder = #allModelsOrdered
    return x
end

function TrafficLightModel.resolve(id)
    return TrafficLightModel.allModels[id]
end

function TrafficLightModel.getAllOrdered()
    local copy = {}
    for i, model in ipairs(allModelsOrdered) do copy[i] = model end
    return copy
end

function TrafficLightModel:matchModelNames(...)
    local patterns = {}
    for _, pattern in ipairs({ ... }) do
        assert(type(pattern) == "string", "Need model name pattern as string")
        table.insert(patterns, string.lower(pattern))
    end
    self.modelNamePatterns = patterns
    return self
end

local function basename(value)
    return string.match(value:gsub("\\", "/"), "([^/]+)$") or value
end

local function normalizedModelName(value)
    return string.lower(string.gsub(basename(value), "%.[^.]+$", ""))
end

function TrafficLightModel.inferFromItemName(itemNameWithModelPath)
    if not itemNameWithModelPath then return nil end
    local modelName = normalizedModelName(itemNameWithModelPath)
    for _, model in ipairs(allModelsOrdered) do
        for _, pattern in ipairs(model.modelNamePatterns or {}) do
            if string.match(modelName, pattern) then return model end
        end
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
local TLM = TrafficLightModel

-- Fuer die Strassenbahnsignale von MA1 - http://www.eep.euma.de/downloads/V80MA1F003.zip
TLM.MA1_STRAB_4er_2_gruen = TLM:new(
    "MA1_STRAB_4er_2_gruen",
    "MA1 4er-Straba (Halt, Halt erwarten, Fahrt (2))",
    1, -- red: "Halt" (1)
    2, -- green: "Fahrt geradeaus/rechts/links" (2)
    4, -- yellow: "Halt erwarten" (3)
    4  -- redYellow: "Halt erwarten" (3)
)
TLM.MA1_STRAB_4er_3_gruen = TLM:new(
    "MA1_STRAB_4er_3_gruen",
    "MA1 4er-Straba (Halt, Halt erwarten, Fahrt (3))",
    1, -- red: "Halt" (1)
    3, -- green: "Fahrt geradeaus/rechts/links" (2)
    4, -- yellow: "Halt erwarten" (3)
    4  -- redYellow: "Halt erwarten" (3)
)
TLM.MA1_STRAB_2er_2_gruen = TLM:new(
    "MA1_STRAB_2er_2_gruen",
    "MA1 4er-Straba (Halt, Fahrt)",
    1, -- red: "Halt" (1)
    2, -- green: "Fahrt geradeaus" (2)
    1, -- yellow: defaults to red: "Halt" (1)
    1, -- redYellow: defaults to red: "Halt" (1)
    1, -- pedestrian: defaults to red: "Halt" (1)
    2, -- off: defaults to green: "Fahrt geradeaus" (2)
    2, -- blinkYellow: defaults to off: "Fahrt geradeaus" (2)
    2  -- greenYellow: defaults to green: "Fahrt geradeaus" (2)
):matchModelNames(
    "^strabahnsignal_01_ma1$"
)
TLM.MA1_STRAB_3er_2_gruen = TLM:new(
    "MA1_STRAB_3er_2_gruen",
    "MA1 4er-Straba (Halt, Halt erwarten, Fahrt)",
    1,   -- red: "Halt" (1)
    2,   -- green: "Fahrt geradeaus/rechts/links" (2)
    3,   -- yellow: "Halt erwarten" (3)
    3,   -- redYellow: "Halt erwarten" (3)
    nil, -- pedestrian: old default nil
    nil, -- off: old default to green (2)
    nil, -- blinkYellow: old default nil
    nil  -- greenYellow: old default to green (2)
):matchModelNames(
    "^strabahnsignal_05_ma1$",
    "^strabahnsignal_06_ma1$",
    "^strabahnsignal_07_ma1$"
)

-- Fuer die Ampeln von NP1 - http://eepshopping.de - Ampelset 1 und Ampelset 2
TLM.NP1_2er_nur_FG = TLM:new(
    "NP1_2er_nur_FG",
    "NP1 2er-Ampel (nur Fussgaenger)",
    2, -- red: "Fussg-rot" (2)
    2, -- green: defaults to red: "Fussg-rot" (2)
    2, -- yellow: defaults to red: "Fussg-rot" (2)
    2, -- redYellow: defaults to red: "Fussg-rot" (2)
    1, -- pedestrian: "Fussg-gruen" (1)
    2, -- off: defaults to red: "Fussg-rot" (2)
    2, -- blinkYellow: defaults to off: "Fussg-rot" (2)
    2  -- greenYellow: defaults to green: "Fussg-rot" (2)
):matchModelNames(
    "^ampel_nurfussg.*_np1$"
)

TLM.NP1_3er_mit_FG = TLM:new(
    "NP1_3er_mit_FG",
    "NP1 3er-Ampel mit Fußgängern",
    2,   -- red: "FG-rot/PKW-rot" (2)
    4,   -- green: "FG-rot/PKW-gruen" (4)
    5,   -- yellow: "FG-rot/PKW-gelb" (5)
    3,   -- redYellow: "FG-rot/PKW-rot/gelb" (3)
    1,   -- pedestrian: "FG-gruen/PKW-rot" (1)
    nil, -- off: old default to green (4)
    nil, -- blinkYellow: old default nil
    nil  -- greenYellow: old default to green (4)
):matchModelNames(
    "^ampel_.*_fd.*_np1$",
    "^ampel_.*_fe.*_np1$"
)

TLM.NP1_3er_ohne_FG = TLM:new(
    "NP1_3er_ohne_FG",
    "NP1 3er-Ampel ohne Fußgänger",
    1,   -- red: "PKW-rot" (1)
    3,   -- green: "PKW-gruen" (3)
    4,   -- yellow: "PKW-gelb" (4)
    2,   -- redYellow: "PKW-rot/gelb" (2)
    nil, -- pedestrian: old default nil
    nil, -- off: old default to green (3)
    nil, -- blinkYellow: old default nil
    nil  -- greenYellow: old default to green (3)
):matchModelNames(
    "^ampel_.*_of.*_np1$",
    "^ampel_2spur.*mitte.*_np1$"
)

TLM.NP1_Baustellen_4er = TLM:new(
    "NP1_Baustellen_4er",
    "NP1 Baustellenampel 4er",
    1, -- red: "Rot" (1)
    3, -- green: "Guen" (3)
    4, -- yellow: "Gellb" (4)
    2, -- redYellow: "Rot/Gelb" (2)
    1, -- pedestrian: defaults to red: "Rot" (1)
    3, -- off: defaults to green: "Guen" (3)
    3, -- blinkYellow: defaults to off: "Guen" (3)
    3  -- greenYellow: defaults to green: "Guen" (3)
):matchModelNames(
    "^baustellenampel.*_np1$"
)

-- Fuer die Ampeln von JS2 - http://eepshopping.de - Ampel-Baukasten (V80NJS20039)
TLM.JS2_2er_nur_FG = TLM:new(
    "JS2_2er_nur_FG",
    "JS2 2er-Ampel (nur Fußgänger)",
    1, -- red: "FG-rot" (1)
    1, -- green: defaults to red: "FG-rot" (1)
    1, -- yellow: defaults to red: "FG-rot" (1)
    1, -- redYellow: defaults to red: "FG-rot" (1)
    2, -- pedestrian: "FG-gruen" (2)
    3, -- off: "Ampel aus" (3)
    3, -- blinkYellow: defaults to off: "Ampel aus" (3)
    4  -- greenYellow: old compatibility value (4)
):matchModelNames(
    "^2erfg.*_js2$",
    "^3erfg.*_js2$"
)

TLM.JS2_2er_gelb_gruen_aus = TLM:new(
    "JS2_2er_gelb_gruen_aus",
    "JS2 2er-Ampel (gelb/grün)",
    1, -- red: "Ampel aus - Halt" (1)
    3, -- green: "PKW--gruen" (3)
    5, -- yellow: "PKW--gelb" (5)
    1, -- redYellow: defaults to red: "Ampel aus - Halt" (1)
    1, -- pedestrian: defaults to red: "Ampel aus - Halt" (1)
    2, -- off: "Ampel aus - Fahrt" (2)
    6, -- blinkYellow: "Gelb blinken" (6)
    4  -- greenYellow: "PKW--gruen/gelb" (4)
):matchModelNames(
    "^2ergruengelb.*_js2$"
)
TLM.JS2_2er_OFF_YELLOW_GREEN = TLM.JS2_2er_gelb_gruen_aus

TLM.JS2_2er_rot_gelb_aus = TLM:new(
    "JS2_2er_rot_gelb_aus",
    "JS2 2er-Ampel (rot/gelb/aus)",
    1, -- red: "rot" (1)
    3, -- green: "Ampel aus" (3)
    2, -- yellow: "gelb" (2)
    4, -- redYellow: "rot/gelb" (4)
    1, -- pedestrian: defaults to red: "rot" (1)
    3, -- off: "Ampel aus" (3)
    5, -- blinkYellow: "gelb blinkend" (5)
    3  -- greenYellow: defaults to green: "Ampel aus" (3)
):matchModelNames(
    "^2errotgelbausleger_js2$",
    "^2errotgelbmast_js2$",
    "^2errotgelbmitte_js2$",
    "^2errotgelbohnemast_js2$"
)

TLM.JS2_2er_rot_gelb_gruen_aus = TLM:new(
    "JS2_2er_rot_gelb_gruen_aus",
    "JS2 2er-Ampel (rot/gelb/gruen/aus)",
    1, -- red: "PKW--rot" (1)
    3, -- green: "PKW--gruen--Ampel aus" (3)
    4, -- yellow: "PKW--gelb" (4)
    2, -- redYellow: "PKW--rot/gelb" (2)
    1, -- pedestrian: defaults to red: "PKW--rot" (1)
    3, -- off: "PKW--gruen--Ampel aus" (3)
    3, -- blinkYellow: defaults to off: "PKW--gruen--Ampel aus" (3)
    3  -- greenYellow: defaults to green: "PKW--gruen--Ampel aus" (3)
):matchModelNames(
    "^2errotgelbausleggerade.*_js2$",
    "^2errotgelbausleglinks.*_js2$",
    "^2errotgelbauslegnormal.*_js2$",
    "^2errotgelbauslegrechts.*_js2$",
    "^2errotgelbausli.*_js2$",
    "^2errotgelbgerade.*_js2$",
    "^2errotgelblinks.*_js2$",
    "^2errotgelbnormal.*_js2$",
    "^2errotgelbrechts.*_js2$"
)

TLM.JS2_2er_rot_gruen = TLM:new(
    "JS2_2er_rot_gruen",
    "JS2 2er-Ampel (rot/grün)",
    1, -- red: "Rot" (1)
    2, -- green: "Gruen" (2)
    1, -- yellow: defaults to red: "Rot" (1)
    1, -- redYellow: defaults to red: "Rot" (1)
    1, -- pedestrian: defaults to red: "Rot" (1)
    3, -- off: "Ampel aus" (3)
    3, -- blinkYellow: defaults to off: "Ampel aus" (3)
    2  -- greenYellow: defaults to green: "Gruen" (2)
):matchModelNames(
    "^2errotgruen.*_js2$"
)

TLM.JS2_1er_gruen = TLM:new(
    "JS2_1er_gruen",
    "JS2 1er-Ampel (grün)",
    1, -- red: "Ampel aus" (1)
    2, -- green: "gruen" (2)
    1, -- yellow: defaults to red: "Ampel aus" (1)
    1, -- redYellow: defaults to red: "Ampel aus" (1)
    1, -- pedestrian: defaults to red: "Ampel aus" (1)
    1, -- off: "Ampel aus" (1)
    1, -- blinkYellow: defaults to off: "Ampel aus" (1)
    2  -- greenYellow: defaults to green: "gruen" (2)
):matchModelNames(
    "^1erlinks.*_js2$"
)

TLM.JS2_3er_mit_FG = TLM:new(
    "JS2_3er_mit_FG",
    "JS2 3er-Ampel mit Fußgängern",
    1, -- red: "PKW--rot FG--rot" (1)
    3, -- green: "PKW--gruen" (3)
    5, -- yellow: "PKW--gelb" (5)
    2, -- redYellow: "PKW--rot/gelb" (2)
    6, -- pedestrian: "PKW--rot FG--gruen" (6)
    7, -- off: old compatibility value (7)
    8, -- blinkYellow: old compatibility value (8)
    4  -- greenYellow: "PKW--gruen/gelb" (4)
):matchModelNames(
    "^3er.*fg.*_js2$"
)

TLM.JS2_3er_ohne_FG = TLM:new(
    "JS2_3er_ohne_FG",
    "JS2 3er-Ampel ohne Fußgänger",
    1, -- red: "PKW--rot" (1)
    3, -- green: "PKW--gruen" (3)
    5, -- yellow: "PKW--gelb" (5)
    2, -- redYellow: "PKW--rot/gelb" (2)
    1, -- pedestrian: defaults to red: "PKW--rot" (1)
    6, -- off: old compatibility value (6)
    7, -- blinkYellow: old compatibility value (7)
    4  -- greenYellow: "PKW--gruen/gelb" (4)
):matchModelNames(
    "^3er.*_js2$"
)

-- Fuer die Ampeln von DH1
TLM.DH1_blink_gelb_fahrt_halt = TLM:new(
    "DH1_blink_gelb_fahrt_halt",
    "DH1 Blinkampel Halt/Fahrt",
    1, -- red: "Halt Achtung" (1)
    2, -- green: "Fahrt Achtung" (2)
    1, -- yellow: defaults to red: "Halt Achtung" (1)
    1, -- redYellow: defaults to red: "Halt Achtung" (1)
    1, -- pedestrian: defaults to red: "Halt Achtung" (1)
    3, -- off: "ausgeschaltet" (3)
    1, -- blinkYellow: "Halt Achtung" (1)
    2  -- greenYellow: defaults to green: "Fahrt Achtung" (2)
):matchModelNames(
    "^ampel_gblfh_dh1$",
    "^ampvv_gblfh_dh1$"
)

TLM.DH1_blink_gelb = TLM:new(
    "DH1_blink_gelb",
    "DH1 Blinkampel gelb",
    2, -- red: "ausgeschaltet" (2)
    1, -- green: "Achtung" (1)
    2, -- yellow: "ausgeschaltet" (2)
    1, -- redYellow: defaults to yellow: "Achtung" (1)
    2, -- pedestrian: defaults to off: "ausgeschaltet" (2)
    2, -- off: "ausgeschaltet" (2)
    1, -- blinkYellow: "Achtung" (1)
    2  -- greenYellow: defaults to green: "ausgeschaltet" (2)
):matchModelNames(
    "^ampel_gbl_dh1$",
    "^ampel2_gbl_dh1$",
    "^ampvv_gbl_dh1$"
)

TLM.DH1_zusatz_rechts = TLM:new(
    "DH1_zusatz_rechts",
    "DH1 Zusatzsignal rechts",
    2, -- red: "ausgeschaltet" (2)
    1, -- green: "Fahrt" (1)
    2, -- yellow: defaults to off: "ausgeschaltet" (2)
    2, -- redYellow: defaults to off: "ausgeschaltet" (2)
    2, -- pedestrian: defaults to off: "ausgeschaltet" (2)
    2, -- off: "ausgeschaltet" (2)
    2, -- blinkYellow: defaults to off: "ausgeschaltet" (2)
    1  -- greenYellow: defaults to green: "Fahrt" (1)
):matchModelNames(
    "^ampel_zus_rechts_dh1$",
    "^ampel2_zus_rechts_dh1$"
)

TLM.DH1_2er_FG = TLM:new(
    "DH1_2er_FG",
    "DH1 2er-Ampel nur Fussgaenger",
    2, -- red: "Halt" (2)
    2, -- green: defaults to red: "Halt" (2)
    2, -- yellow: defaults to red: "Halt" (2)
    2, -- redYellow: defaults to red: "Halt" (2)
    1, -- pedestrian: "gehen" (1)
    2, -- off: defaults to red: "Halt" (2)
    2, -- blinkYellow: defaults to off: "Halt" (2)
    2  -- greenYellow: defaults to green: "Halt" (2)
):matchModelNames(
    "^ampel_fg_2fach.*_dh1$",
    "^ampel_fg_3fach.*_dh1$",
    "^ampel2_fg_2fach.*_dh1$",
    "^ampel2_fg_3fach.*_dh1$"
)

TLM.DH1_3er_FG_mit_gelb = TLM:new(
    "DH1_3er_FG_mit_gelb",
    "DH1 3er-Ampel nur Fussgaenger",
    1, -- red: "Halt" (1)
    1, -- green: defaults to red: "Halt" (1)
    4, -- yellow: "Halt erwarten" (4)
    2, -- redYellow: "gruen erwarten" (2)
    3, -- pedestrian: "gehen" (3)
    5, -- off: "ausgeschaltet" (5)
    5, -- blinkYellow: defaults to off: "ausgeschaltet" (5)
    4  -- greenYellow: "Halt erwarten" (4)
):matchModelNames(
    "^ampel_fg_3f_rgg.*_dh1$"
)

TLM.DH1_3er_FG_mit_gelb_typ2 = TLM:new(
    "DH1_3er_FG_mit_gelb_typ2",
    "DH1 3er-Ampel nur Fussgaenger Typ 2",
    1, -- red: "Halt" (1)
    1, -- green: defaults to red: "Halt" (1)
    4, -- yellow: "Halt erwarten" (4)
    2, -- redYellow: "gruen erwarten" (2)
    3, -- pedestrian: "Fahrt" (3)
    5, -- off: "ausgeschaltet" (5)
    5, -- blinkYellow: defaults to off: "ausgeschaltet" (5)
    4  -- greenYellow: "Halt erwarten" (4)
):matchModelNames(
    "^ampel2_fg_3f_rgg.*_dh1$"
)

TLM.DH1_2er_rot_gruen = TLM:new(
    "DH1_2er_rot_gruen",
    "DH1 2er-Ampel rot/gruen",
    1, -- red: "Halt" (1)
    2, -- green: "Fahrt" (2)
    1, -- yellow: defaults to red: "Halt" (1)
    1, -- redYellow: defaults to red: "Halt" (1)
    1, -- pedestrian: defaults to red: "Halt" (1)
    3, -- off: "ausgeschaltet" (3)
    3, -- blinkYellow: defaults to off: "ausgeschaltet" (3)
    2  -- greenYellow: defaults to green: "Fahrt" (2)
):matchModelNames(
    "^are2xrg_dh1$"
)

TLM.DH1_2er_gelb_gruen = TLM:new(
    "DH1_2er_gelb_gruen",
    "DH1 2er-Ampel gelb/gruen",
    1, -- red: "Halt" (1)
    3, -- green: "Fahrt" (3)
    2, -- yellow: "Fahr erwarten" (2)
    1, -- redYellow: defaults to red: "Halt" (1)
    1, -- pedestrian: defaults to red: "Halt" (1)
    3, -- off: defaults to green: "Fahrt" (3)
    2, -- blinkYellow: defaults to yellow: "Fahr erwarten" (2)
    2  -- greenYellow: "Fahr erwarten" (2)
):matchModelNames(
    "^are2xgg_dh1$"
)

TLM.DH1_3er = TLM:new(
    "DH1_3er",
    "DH1 3er-Ampel",
    1, -- red: "Halt" (1)
    3, -- green: "Fahrt" (3)
    4, -- yellow: "Halt erwarten" (4)
    2, -- redYellow: "Fahrt erwarten" (2)
    1, -- pedestrian: defaults to red: "Halt" (1)
    5, -- off: "ausgeschaltet" (5)
    5, -- blinkYellow: defaults to off: "ausgeschaltet" (5)
    4  -- greenYellow: "Halt erwarten" (4)
):matchModelNames(
    "^ampel_.*_dh1$",
    "^ampel2_.*_dh1$"
)

-- Unsichtbare Ampeln haben "nur" rot und gruen
TLM.Unsichtbar_2er = TLM:new(
    "Unsichtbar_2er",
    "Unsichtbares Signal",
    2, -- red
    1, -- green
    2, -- yellow: defaults to red
    2, -- redYellow: defaults to red
    2, -- pedestrian: defaults to red
    1, -- off: defaults to green
    1, -- blinkYellow: defaults to off
    1  -- greenYellow: defaults to green
):matchModelNames(
    "^signal_unsichtbar$"
)

-- Kein Signal
TLM.NONE = TLM:new("NONE", "NO SIGNAL MODEL", 1, 2, 3, 4, 5, 6, 7)

return TrafficLightModel
