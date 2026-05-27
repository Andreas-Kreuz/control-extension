if CeDebugLoad then print("[#Start] Loading ce.mods.road.tipptext.RoadSignalTippTextComposer ...") end

local SignalIndication = require("ce.mods.road.SignalIndication")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local fmt = require("ce.hub.eep.TippTextFormatter")

local RoadSignalTippTextComposer = {}

local function textIsNotEmpty(text)
    return text and text:len() > 0
end

local function shortTippName(name)
    return name and string.match(name, "^([^_]+)") or nil
end

local function signalModelFacts(signalId, trafficLightModel)
    local facts = {
        trafficLightModel = trafficLightModel
    }
    if signalId > 0 then
        local signal = SignalRegistry.getOrCreate(signalId)
        signal:getItemName()
        facts.trafficLightModelName = signal:getItemNameWithModelPath()
        facts.trafficLightModel = TrafficLightModel.inferFromItemName(facts.trafficLightModelName) or
            trafficLightModel
        facts.currentPosition = signal:pullPosition()
        facts.signalFunctions = signal:getFunctions() or {}
    end
    return facts
end

local function signalName(trafficLight, pedestrian)
    local name = pedestrian and trafficLight:getPedestrianSignalName() or trafficLight:getVehicleSignalName()
    return name and "<b>" .. shortTippName(name) .. "</b>" or ""
end

local function vehicleSignalNameTippText(trafficLight)
    local name = signalName(trafficLight, false)
    local indication = trafficLight:getCurrentIndication()
    if indication == SignalIndication.GREEN then
        return fmt.green(name)
    elseif indication == SignalIndication.OFF then
        return fmt.greyText(name)
    elseif indication == SignalIndication.YELLOW or indication == SignalIndication.REDYELLOW or
        indication == SignalIndication.GREENYELLOW or indication == SignalIndication.OFF_BLINKING then
        return fmt.bgYellow(name)
    else
        return fmt.bgRed(name)
    end
end

local function pedestrianSignalNameTippText(trafficLight)
    local name = signalName(trafficLight, true)
    local indication = trafficLight:getCurrentIndication()
    if indication == SignalIndication.PEDESTRIAN then
        return fmt.green(name)
    elseif indication == SignalIndication.OFF or indication == SignalIndication.OFF_BLINKING then
        return fmt.greyText(name)
    else
        return fmt.bgRed(name)
    end
end

local function signalNamesTippText(trafficLight)
    if trafficLight:getUse() == TrafficLight.Use.PEDESTRIAN_ONLY then
        return pedestrianSignalNameTippText(trafficLight)
    elseif trafficLight:getUse() == TrafficLight.Use.VEHICLE_AND_PEDESTRIAN then
        return vehicleSignalNameTippText(trafficLight) .. "<br>" .. pedestrianSignalNameTippText(trafficLight)
    else
        return vehicleSignalNameTippText(trafficLight)
    end
end

local function signalIsPartOfSignalGroup(trafficLight)
    return next(trafficLight:getSignalGroupsByUse() or {}) ~= nil
end

local function signalModelFingerprint(signalId, trafficLightModel)
    local values = { trafficLightModel.name }
    if signalId <= 0 then return table.concat(values, ":") end

    local signal = SignalRegistry.get(signalId)
    if not signal then return table.concat(values, ":") end

    local itemNameWithModelPath = signal:getItemNameWithModelPath()
    local currentPosition = signal:pullPosition()
    local signalFunctions = signal:getFunctions() or {}
    table.insert(values, itemNameWithModelPath or "")
    table.insert(values, currentPosition or "")
    table.insert(values, table.concat(signalFunctions, "|"))
    return table.concat(values, ":")
end

function RoadSignalTippTextComposer.fingerprint(trafficLight, options)
    local values = { trafficLight:getSignalId() }
    if options.showModelInfoOnSignal then
        table.insert(values, signalModelFingerprint(trafficLight:getSignalId(), trafficLight:getTrafficLightModel()))
    end
    if options.showLaneNamesOnSignal or options.showNameAndPhaseOnSignal then
        table.insert(values, trafficLight:getVehicleSignalName() or "")
        table.insert(values, trafficLight:getPedestrianSignalName() or "")
        table.insert(values, trafficLight:getUse())
        table.insert(values, trafficLight:getCurrentIndication() or "")
    end
    if options.showNameAndPhaseOnSignal then
        table.insert(values, tostring(signalIsPartOfSignalGroup(trafficLight)))
    end
    if options.showPhaseOnSignal then
        table.insert(values, trafficLight:getCurrentIndication() or "")
        table.insert(values, trafficLight:getReason() or "")
    end
    if trafficLight:getSignalId() <= 0 then
        for _, structureName in ipairs(trafficLight:getAllTippTextStructures()) do
            table.insert(values, structureName)
        end
    end
    return table.concat(values, ":")
end

function RoadSignalTippTextComposer.composeTippText(trafficLight, lane, phaseInfo, options)
    local signalId = trafficLight:getSignalId()
    local primaryStructureName = trafficLight:getPrimaryTippTextStructure()
    local modelFacts = options.showModelInfoOnSignal and
        signalModelFacts(signalId, trafficLight:getTrafficLightModel()) or nil
    local showPhase = options.showPhaseOnSignal and textIsNotEmpty(phaseInfo)
    local showNameAndColor = options.showNameAndPhaseOnSignal and
        (not lane or signalIsPartOfSignalGroup(trafficLight))
    local requestState = options.showRequestsOnSignal and lane and lane:getRequestState() or nil
    local laneKpId = options.showLaneNamesOnSignal and lane and lane:getKpId() or nil
    local reasonText = ""
    if showPhase and not showNameAndColor and trafficLight:getCurrentIndication() and trafficLight:getReason() then
        reasonText = string.format(" %s (%s) ", trafficLight:getCurrentIndication(), trafficLight:getReason())
    end

    local infoText = "<j>"
    -- Tracks whether any block has already written visible TippText content.
    -- This is needed for both final show/hide and inserting separators before following blocks.
    local tippTextIsShown = false

    -- Signal-ID: real signals show their signal id, structure lights show the housing id.
    if options.showSignalIdOnSignal then
        if signalId > 0 then
            infoText = fmt.appendUpTo1023(infoText, "Signal: " .. signalId)
        elseif primaryStructureName then
            infoText = fmt.appendUpTo1023(infoText, "Immo: " .. shortTippName(primaryStructureName))
        else
            infoText = fmt.appendUpTo1023(infoText, "Signal: " .. signalId)
        end
        tippTextIsShown = true
    end

    -- Model information: model name/path plus all known signal functions, current position highlighted.
    if modelFacts then
        if tippTextIsShown then infoText = fmt.appendUpTo1023(infoText, "<br>") end
        infoText = fmt.appendUpTo1023(infoText, modelFacts.trafficLightModel.name)
        if modelFacts.trafficLightModelName then
            infoText = fmt.appendUpTo1023(infoText, "<br>")
            infoText = fmt.appendUpTo1023(infoText, modelFacts.trafficLightModelName)
            for i, action in ipairs(modelFacts.signalFunctions) do
                infoText = fmt.appendUpTo1023(infoText, "<br>")
                infoText = fmt.appendUpTo1023(infoText, modelFacts.currentPosition == i and "<b>" or "")
                infoText = fmt.appendUpTo1023(infoText, tostring(i))
                infoText = fmt.appendUpTo1023(infoText, ": ")
                infoText = fmt.appendUpTo1023(infoText, modelFacts.trafficLightModel:indicationOf(i) or action)
                infoText = fmt.appendUpTo1023(infoText, modelFacts.currentPosition == i and "</b>." or ".")
            end
        end
        tippTextIsShown = true
    end

    -- Lane signal display: lane-signal short name/color together with the lane name.
    if options.showLaneNamesOnSignal and lane then
        if tippTextIsShown then infoText = fmt.appendUpTo1023(infoText, "<br>") end
        infoText = fmt.appendUpTo1023(infoText, signalNamesTippText(trafficLight))
        infoText = fmt.appendUpTo1023(infoText, " ")
        infoText = fmt.appendUpTo1023(infoText, fmt.bgLightBlue(lane:getName()))
        if laneKpId then
            infoText = fmt.appendUpTo1023(infoText, " (")
            infoText = fmt.appendUpTo1023(infoText, laneKpId)
            infoText = fmt.appendUpTo1023(infoText, ")")
        end
        infoText = fmt.appendUpTo1023(infoText, ".")
        tippTextIsShown = true
    end

    -- Short name/color display: normal signal heads and grouped lane signals only.
    if showNameAndColor then
        if tippTextIsShown then infoText = fmt.appendUpTo1023(infoText, "<br>") end
        infoText = fmt.appendUpTo1023(infoText, signalNamesTippText(trafficLight))
        tippTextIsShown = true
    end

    -- Waiting vehicles: lane request source and queued vehicle names.
    if requestState then
        if tippTextIsShown then infoText = fmt.appendUpTo1023(infoText, "<br>") end
        infoText = fmt.appendUpTo1023(infoText,
                                      requestState.occupied and fmt.bgGrey("BELEGT") or fmt.bgGrey("-FREI-"))
        infoText = fmt.appendUpTo1023(infoText, " ")
        if requestState.source == "track" then
            infoText = fmt.appendUpTo1023(infoText, "(Strasse)")
        elseif requestState.source == "signal" then
            infoText = fmt.appendUpTo1023(infoText, "(Ampel)")
        else
            infoText = fmt.appendUpTo1023(infoText, "(" .. requestState.vehicleCount .. " gezaehlt " ..
                requestState.requestType .. ") ")
        end
        for _, vehicleName in ipairs(requestState.queuedVehicleNames) do
            infoText = fmt.appendUpTo1023(infoText, "<br>")
            infoText = fmt.appendUpTo1023(infoText, vehicleName)
        end
        tippTextIsShown = true
    end

    if not tippTextIsShown and not showPhase then return "" end

    -- Phase information: phase matrix is separated more strongly from the signal-local blocks.
    if showPhase then
        if tippTextIsShown then infoText = fmt.appendUpTo1023(infoText, "<br><br>") end
        infoText = fmt.appendUpTo1023(infoText, "<b>" .. "Phase: " .. "</b>")
        infoText = fmt.appendUpTo1023(infoText, phaseInfo)
    end

    -- Current indication/reason is only extra context when short name/color is not already shown.
    if textIsNotEmpty(reasonText) then
        infoText = fmt.appendUpTo1023(infoText, "<br><br>")
        infoText = fmt.appendUpTo1023(infoText, reasonText)
    end
    return infoText
end

function RoadSignalTippTextComposer.state(trafficLight, lane, phaseInfo, options)
    local infoText = RoadSignalTippTextComposer.composeTippText(trafficLight, lane, phaseInfo, options)
    return {
        visible = textIsNotEmpty(infoText),
        text = infoText
    }
end

return RoadSignalTippTextComposer
