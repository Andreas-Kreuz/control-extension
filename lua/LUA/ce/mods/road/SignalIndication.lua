if CeDebugLoad then print("[#Start] Loading ce.mods.road.SignalIndication ...") end

---@class SignalIndication
local SignalIndication = {}
SignalIndication.RED = "Rot"
SignalIndication.REDYELLOW = "Rot-Gelb"
SignalIndication.YELLOW = "Gelb"
SignalIndication.GREEN = "Gruen"
SignalIndication.GREENYELLOW = "Gruen-Gelb"
SignalIndication.PEDESTRIAN = "Fussg"
SignalIndication.OFF = "Aus"
SignalIndication.OFF_BLINKING = "Aus blinkend"
SignalIndication.UNKNOWN = "UNBEKANNT"

function SignalIndication.canDrive(indication)
    return indication == SignalIndication.GREEN or indication == SignalIndication.OFF or indication ==
        SignalIndication.OFF_BLINKING
end

return SignalIndication
