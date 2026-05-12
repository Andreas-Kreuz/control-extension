if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLight ...") end

local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local AxisStructureTrafficLight = require("ce.mods.road.AxisStructureTrafficLight")
local LightStructureTrafficLight = require("ce.mods.road.LightStructureTrafficLight")
local TrafficLightState = require("ce.mods.road.TrafficLightState")
local fmt = require("ce.hub.eep.TippTextFormatter")

------------------------------------------------------------------------------------------
-- Klasse TrafficLight
-- Ampel mit einer festen signalId und einem festen Ampeltyp
-- Optional kann die Ampel bei Immobilien Licht ein- und ausschalten (Straba - Ampelsatz)
------------------------------------------------------------------------------------------
local TrafficLight = {}
TrafficLight.debug = CeStartWithDebug or false
TrafficLight.Use = {
    TRAFFIC_ONLY = "TRAFFIC_ONLY",
    PEDESTRIAN_ONLY = "PEDESTRIAN_ONLY",
    TRAFFIC_AND_PEDESTRIAN = "TRAFFIC_AND_PEDESTRIAN"
}
local registeredSignals = {}
local counter = -1

---
---@param name string Name der Ampel
---@param signalId number ID der Ampel auf der Anlage (Eine Ampel von diesem Typ sollte auf der Anlage sein)
---@param trafficLightModel TrafficLightModel Typ der Ampel (TrafficLightModel)
---@param redStructure? string Immobilie fuer Signalbild gelb (Licht an / aus)
---@param greenStructure? string Immobilie fuer Signalbild gelb (Licht an / aus)
---@param yellowStructure? string Immobilie fuer Signalbild gelb (Licht an / aus)
---@param requestStructure? string Immobilie fuer Signalbild "A" (Licht an / aus)
--
function TrafficLight:new(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                          requestStructure)
    assert(signalId, "Specify a signalId")
    assert(trafficLightModel, "Specify a trafficLightModel")
    local error = string.format("Signal ID already used: %s - %s", signalId, trafficLightModel.name)
    assert(not registeredSignals[tostring(signalId)] or registeredSignals[tostring(signalId)].trafficLightModel ==
           trafficLightModel, error)
    EEPShowInfoSignal(signalId, false)
    if signalId < 0 then counter = counter - 1 end
    local o = {
        trafficSignalName = name,
        pedestrianSignalName = nil,
        use = TrafficLight.Use.TRAFFIC_ONLY,
        signalId = signalId > 0 and signalId or counter,
        trafficLightModel = trafficLightModel,
        phase = signalId > 0 and trafficLightModel:phaseOf(EEPGetSignal(signalId)) or TrafficLightState.RED,
        debug = false,
        laneInfo = "",
        sequenceInfo = nil,
        buildInfo = "" .. tostring(signalId),
        lanes = {},
        ---@type table<LightStructureTrafficLight,boolean>
        lightStructures = {},
        ---@type table<AxisStructureTrafficLight,boolean>
        axisStructures = {},
        type = "TrafficLight"
    }
    self.__index = self
    o = setmetatable(o, self)

    if redStructure or greenStructure or yellowStructure or requestStructure then
        o:addLightStructure(redStructure, greenStructure, yellowStructure, requestStructure)
    end

    registeredSignals[tostring(signalId)] = o
    return o
end

function TrafficLight:newPedestrianOnly(name, signalId, trafficLightModel, redStructure, greenStructure,
                                        yellowStructure, requestStructure)
    return self:new(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                    requestStructure):asPedestrianOnly()
end

function TrafficLight:withPedestrian(pedestrianSignalName)
    assert(type(pedestrianSignalName) == "string", "Need 'pedestrianSignalName' as string")
    self.pedestrianSignalName = pedestrianSignalName
    self.use = TrafficLight.Use.TRAFFIC_AND_PEDESTRIAN
    return self
end

function TrafficLight:asPedestrianOnly()
    self.pedestrianSignalName = self.pedestrianSignalName or self.trafficSignalName
    self.trafficSignalName = nil
    self.use = TrafficLight.Use.PEDESTRIAN_ONLY
    return self
end

--- Schaltet das Licht der angegebenen Immobilien beim Schalten der Ampel auf rot, gelb, gr¸n oder Anforderung
-- @param redStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel rot oder rot-gelb ist
-- @param greenStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel gr¸n ist
-- @param yellowStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel gelb oder rot-gelb ist
-- @param requestStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel eine Anforderung erkennt
--
function TrafficLight:addLightStructure(redStructure, greenStructure, yellowStructure, requestStructure)
    local lightStructure = LightStructureTrafficLight:new(redStructure, greenStructure, yellowStructure,
                                                          requestStructure)
    self.lightStructures[lightStructure] = true
    return self
end

--- ƒndert die Achsstellung der angegebenen Immobilien beim Schalten der Ampel auf rot, gelb, gr¸n oder Fuﬂg‰nger
-- @param structureName Name der Immobilie, deren Achse gesteuert werden soll
-- @param axisName Name der Achse in der Immobilie, die gesteuert werden soll
-- @param positionDefault Grundstellung der Achse (wird eingestellt, wenn eine Stellung nicht angegeben wurde
-- @param positionRed Achsstellung bei rot
-- @param positionGreen Achsstellung bei gr¸n
-- @param positionYellow Achsstellung bei gelb
-- @param positionRedYellow Achsstellung bei gelbrot
-- @param positionPedestrian Achsstellung bei FG
--
function TrafficLight:addAxisStructure(structureName, axisName, positionDefault, positionRed, positionGreen,
                                       positionYellow, positionRedYellow, positionPedestrian)
    local axisStructure = AxisStructureTrafficLight:new(structureName, axisName, positionDefault, positionRed,
                                                        positionGreen, positionYellow, positionRedYellow,
                                                        positionPedestrian)
    self.axisStructures[axisStructure] = true
    return self
end

--- Aktualisiert den Text f¸r die aktuellen Schaltung dieser Ampel
-- @param sequenceInfo TippText f¸r die Schaltung
--
function TrafficLight:setSequenceInfo(sequenceInfo) self.sequenceInfo = sequenceInfo end

--- Aktualsisiert den Text f¸r die Fahrspuren dieser Ampel
-- @param laneInfo TippText f¸r die Fahrspur
--
function TrafficLight:setLaneInfo(laneInfo) self.laneInfo = laneInfo end

function TrafficLight:showInfoText(showInfo)
    if self.signalId > 0 then
        EEPShowInfoSignal(self.signalId, showInfo)
    else
        for l in pairs(self.lightStructures) do
            if l.redStructure then
                EEPShowInfoStructure(l.redStructure, showInfo)
                break
            end
        end
    end
end

function TrafficLight:changeInfoText(infoText)
    if self.signalId > 0 then
        EEPChangeInfoSignal(self.signalId, infoText)
    else
        for l in pairs(self.lightStructures) do
            if l.redStructure then
                EEPChangeInfoStructure(l.redStructure, infoText)
                break
            end
        end
    end
end

local function getSignalFunctionsTippText(signalId, trafficLightModel)
    if EEPGetSignalFunctions then
        local text = {}
        local found, signalModelName = EEPGetSignalItemName(signalId, true)
        if not found then return trafficLightModel.name end
        table.insert(text, trafficLightModel.name)
        table.insert(text, "<br>")
        table.insert(text, signalModelName)
        local _, count = EEPGetSignalFunctions(signalId)
        for i = 1, count do
            local _, action = EEPGetSignalFunction(signalId, i)
            table.insert(text, "<br>")
            table.insert(text, EEPGetSignal(signalId) == i and "<b>" or "")
            table.insert(text, i)
            table.insert(text, ": ")
            table.insert(text, trafficLightModel:phaseOf(i) or action)
            table.insert(text, EEPGetSignal(signalId) == i and "</b>" or "")
        end
        return table.concat(text, "")
    else
        return trafficLightModel.name
    end
end

function TrafficLight:trafficSignalNameTippText()
    local name = self.trafficSignalName and "<b>" .. self.trafficSignalName .. "</b>" or ""
    local phase = self.phase
    if phase == TrafficLightState.GREEN then
        return fmt.green(name)
    elseif phase == TrafficLightState.OFF then
        return fmt.greyText(name)
    elseif phase == TrafficLightState.YELLOW or phase == TrafficLightState.REDYELLOW or
        phase == TrafficLightState.GREENYELLOW or phase == TrafficLightState.OFF_BLINKING then
        return fmt.bgYellow(name)
    else
        return fmt.bgRed(name)
    end
end

function TrafficLight:pedestrianSignalNameTippText()
    local name = self.pedestrianSignalName and "<b>" .. self.pedestrianSignalName .. "</b>" or ""
    local phase = self.phase
    if phase == TrafficLightState.PEDESTRIAN then
        return fmt.green(name)
    elseif phase == TrafficLightState.OFF or phase == TrafficLightState.OFF_BLINKING then
        return fmt.greyText(name)
    else
        return fmt.bgRed(name)
    end
end

function TrafficLight:signalNamesTippText()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then
        return self:pedestrianSignalNameTippText()
    elseif self.use == TrafficLight.Use.TRAFFIC_AND_PEDESTRIAN then
        return self:trafficSignalNameTippText() .. "<br>" .. self:pedestrianSignalNameTippText()
    else
        return self:trafficSignalNameTippText()
    end
end

function TrafficLight:signalNamesText()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then
        return self.pedestrianSignalName or ""
    elseif self.use == TrafficLight.Use.TRAFFIC_AND_PEDESTRIAN then
        return (self.trafficSignalName or "") .. "/" .. (self.pedestrianSignalName or "")
    else
        return self.trafficSignalName or ""
    end
end

--- Stellt die vorher gesetzten Tipp-Texte dar.
--
function TrafficLight:refreshInfo()
    local showSwitching = IntersectionSettings.showSequenceOnSignal
    local showAllSignals = IntersectionSettings.showSignalIdOnSignal
    local showModelInfo = IntersectionSettings.showModelInfoOnSignal
    local showNameAndColor = IntersectionSettings.showNameAndSequenceOnSignal
    local showRequests = IntersectionSettings.showRequestsOnSignal and self.laneInfo:len() > 0
    local showInfo = showSwitching or showAllSignals or showModelInfo or showNameAndColor or showRequests

    self:showInfoText(showInfo)
    if showInfo then
        local infoText = "<j>"

        if showNameAndColor and self.phase then
            local name = showNameAndColor and self:signalNamesTippText() or
                "<b>" .. self:signalNamesText() .. "</b>"
            infoText = fmt.appendUpTo1023(infoText, name)
        else
            local signalName = self:signalNamesText()
            infoText = fmt.appendUpTo1023(infoText, signalName .. " (Signal " .. self.signalId .. ")")
        end

        infoText = fmt.appendUpTo1023(infoText, "<br></j>")

        if showModelInfo then
            local signalFunctionsTippText = getSignalFunctionsTippText(self.signalId, self.trafficLightModel)
            infoText = fmt.appendUpTo1023(infoText, "<br>" .. signalFunctionsTippText)
        end

        if showSwitching and self.sequenceInfo then
            local title = "<br><br><b>" .. "Schaltung: " .. "</b>"
            if infoText:len() > 0 then infoText = fmt.appendUpTo1023(infoText, title) end
            infoText = fmt.appendUpTo1023(infoText, self.sequenceInfo)
        end

        if showSwitching and not showNameAndColor and self.phase and self.reason then
            local title = "<br><br>"
            if infoText:len() > 0 then infoText = fmt.appendUpTo1023(infoText, title) end
            infoText = fmt.appendUpTo1023(infoText, string.format(" %s (%s) ", self.phase, self.reason))
        end

        if showRequests then
            local title = "<br><b>" .. "Fahrspur/Wartezeit: " .. "</b>"
            if infoText:len() > 0 then infoText = fmt.appendUpTo1023(infoText, title) end
            infoText = fmt.appendUpTo1023(infoText, self.laneInfo)
        end

        self:changeInfoText(infoText)
    end
end

function TrafficLight.switchAll(trafficLights, phase, reason)
    for tl in pairs(trafficLights) do tl:switchTo(phase, reason) end
end

---
-- @param signalId ID der Ampel auf der Anlage (Eine Ampel von diesem Typ sollte auf der Anlage sein)
-- @param phase TrafficLightState.xxx
-- @param reason z.B. Name der Schaltung
--
function TrafficLight:switchTo(phase, reason)
    assert(type(phase) == "string", "Need 'phase' as string")
    self.phase = phase
    self.reason = reason
    local lightDbg = self:switchStructureLight()
    local axisDbg = self:switchStructureAxis()

    local sigIndex = self.trafficLightModel:signalIndexOf(self.phase)
    if (self.debug or TrafficLight.debug) then
        print(string.format(
            "[TrafficLight    ] Schalte Ampel %04d auf %s (%01d)%s%s - %s",
            self.signalId,
            self.phase,
            sigIndex,
            lightDbg,
            axisDbg,
            reason
        ))
    end
    self:switchSignal(sigIndex)
    self:changed()
end

function TrafficLight:switchStructureLight()
    local lightDbg = ""
    for lightTL in pairs(self.lightStructures) do
        if lightTL.redStructure then
            local onOff = self.phase == TrafficLightState.RED or self.phase == TrafficLightState.REDYELLOW
            lightDbg = lightDbg .. string.format(", Licht in %s: %s", lightTL.redStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.redStructure, onOff)
        end
        if lightTL.yellowStructure then
            local onOff = self.phase == TrafficLightState.YELLOW or self.phase == TrafficLightState.REDYELLOW
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.yellowStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.yellowStructure, onOff)
        end
        if lightTL.greenStructure then
            local onOff = self.phase == TrafficLightState.GREEN
            lightDbg = lightDbg .. string.format(", Licht in %s: %s", lightTL.greenStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.greenStructure, onOff)
        end
    end
    return lightDbg
end

function TrafficLight:switchStructureAxis()
    local axisDbg = ""
    for axisTL in pairs(self.axisStructures) do
        local position = axisTL.positionDefault

        if axisTL.positionRedYellow and self.phase == TrafficLightState.REDYELLOW then
            position = axisTL.positionRedYellow
        elseif axisTL.positionRed and
            (self.phase == TrafficLightState.YELLOW or self.phase == TrafficLightState.REDYELLOW) then
            position = axisTL.positionRed
        elseif axisTL.positionRed and self.phase == TrafficLightState.RED then
            position = axisTL.positionRed
        elseif axisTL.positionGreen and self.phase == TrafficLightState.GREEN then
            position = axisTL.positionGreen
        elseif axisTL.positionPedestrian and self.phase == TrafficLightState.PEDESTRIAN then
            position = axisTL.positionPedestrian
        end

        axisDbg = axisDbg ..
            string.format(", Achse %s in %s auf: %d", axisTL.axisName, axisTL.structureName, position)
        EEPStructureSetAxis(axisTL.structureName, axisTL.axisName, position)
    end
    return axisDbg
end

function TrafficLight:switchSignal(sigIndex) if self.signalId > 0 then EEPSetSignal(self.signalId, sigIndex, 1) end end

--- Setzt die Anforderung fuer eine Ampel (damit sie weiﬂ, ob eine Anforderung vorliegt)
--- @param hasRequest boolean wo liegt die Anforderung an
function TrafficLight:showRequestOnSignal(hasRequest)
    local lightDbg = ""

    for lightTL in pairs(self.lightStructures) do
        if lightTL.requestStructure then
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.requestStructure, (hasRequest) and "an" or "aus")
            EEPStructureSetLight(lightTL.requestStructure, hasRequest)
        end
    end

    if (self.debug or TrafficLight.debug) and lightDbg ~= "" then
        print(string.format("[TrafficLight    ] Schalte Ampel %04d%s", self.signalId, lightDbg))
    end
    self:refreshInfo()
end

function TrafficLight:print()
    print(string.format(
        "[TrafficLight    ] Ampel %04d: %s (%s)",
        self.signalId,
        self.phase,
        self.trafficLightModel.name
    ))
end

function TrafficLight:changed() for lane in pairs(self.lanes) do lane:trafficLightChanged(self) end end

---@param lane Lane The lane apply this traffic light for
function TrafficLight:applyToLane(lane, ...)
    lane:driveOn(self, ...)
    local laneTrafficLight = lane.laneTrafficLight or lane.trafficLight
    if self ~= laneTrafficLight then laneTrafficLight.lanes[lane] = nil end
    self.lanes[lane] = true
end

return TrafficLight
