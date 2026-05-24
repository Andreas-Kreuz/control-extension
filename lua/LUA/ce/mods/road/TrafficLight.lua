if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLight ...") end

local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local AxisStructureTrafficLight = require("ce.mods.road.AxisStructureTrafficLight")
local LightStructureTrafficLight = require("ce.mods.road.LightStructureTrafficLight")
local SignalIndication = require("ce.mods.road.SignalIndication")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local fmt = require("ce.hub.eep.TippTextFormatter")
local Signal = require("ce.hub.data.signals.Signal")
local Structure = require("ce.hub.data.structures.Structure")

------------------------------------------------------------------------------------------
-- Klasse TrafficLight
-- Ampel mit einer festen signalId und einem festen Ampeltyp
-- Optional kann die Ampel bei Immobilien Licht ein- und ausschalten (Straba - Ampelsatz)
------------------------------------------------------------------------------------------
local TrafficLight = {}
TrafficLight.debug = CeStartWithDebug or false
TrafficLight.Use = {
    VEHICLE_ONLY = "VEHICLE_ONLY",
    PEDESTRIAN_ONLY = "PEDESTRIAN_ONLY",
    VEHICLE_AND_PEDESTRIAN = "VEHICLE_AND_PEDESTRIAN"
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
---@param housingStructure? string Gehaeuse fuer Ampelaufsteller-Tags
---@param blendStructure? string Blendschutz fuer Ampelaufsteller-Tags
--
function TrafficLight:newForSignal(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                                   requestStructure, housingStructure, blendStructure)
    assert(signalId, "Specify a signalId")
    assert(trafficLightModel, "Specify a trafficLightModel")
    local error = string.format("TrafficLight ID already used: %s - %s", signalId, trafficLightModel.name)
    assert(not registeredSignals[tostring(signalId)] or registeredSignals[tostring(signalId)].trafficLightModel ==
           trafficLightModel, error)
    Signal.showTippTextById(signalId, false)
    if signalId < 0 then counter = counter - 1 end
    local o = {
        vehicleSignalName = name,
        pedestrianSignalName = nil,
        use = TrafficLight.Use.VEHICLE_ONLY,
        signalId = signalId > 0 and signalId or counter,
        trafficLightModel = trafficLightModel,
        currentIndication = signalId > 0 and trafficLightModel:indicationOf(EEPGetSignal(signalId)) or
            SignalIndication.RED,
        debug = false,
        laneInfo = "",
        laneNameInfo = "",
        phaseInfo = nil,
        isLaneSignal = false,
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
        o:addLightStructure(redStructure, greenStructure, yellowStructure, requestStructure, housingStructure,
                            blendStructure)
    end

    registeredSignals[tostring(signalId)] = o
    return o
end

function TrafficLight:new(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                          requestStructure, housingStructure, blendStructure)
    return self:newForSignal(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                             requestStructure, housingStructure, blendStructure)
end

function TrafficLight:newPedestrianOnly(name, signalId, trafficLightModel, redStructure, greenStructure,
                                        yellowStructure, requestStructure, housingStructure, blendStructure)
    return self:newForSignal(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure,
                             requestStructure, housingStructure, blendStructure):asPedestrianOnly()
end

function TrafficLight:newForLightStructure(name, redStructure, greenStructure, yellowStructure, requestStructure,
                                           housingStructure, blendStructure)
    return self:newForSignal(name, -1, TrafficLightModel.NONE, redStructure, greenStructure, yellowStructure,
                             requestStructure, housingStructure, blendStructure)
end

function TrafficLight:asPedestrianSignal(pedestrianSignalName)
    assert(type(pedestrianSignalName) == "string", "Need 'pedestrianSignalName' as string")
    self.pedestrianSignalName = pedestrianSignalName
    self.use = TrafficLight.Use.VEHICLE_AND_PEDESTRIAN
    return self
end

function TrafficLight:withPedestrian(pedestrianSignalName) return self:asPedestrianSignal(pedestrianSignalName) end

function TrafficLight:asPedestrianOnly()
    self.pedestrianSignalName = self.pedestrianSignalName or self.vehicleSignalName
    self.vehicleSignalName = nil
    self.use = TrafficLight.Use.PEDESTRIAN_ONLY
    return self
end

--- Schaltet das Licht der angegebenen Immobilien beim Schalten der Ampel auf rot, gelb, gr¸n oder Anforderung
-- @param redStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel rot oder rot-gelb ist
-- @param greenStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel gr¸n ist
-- @param yellowStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel gelb oder rot-gelb ist
-- @param requestStructure Name der Immobilie, deren Licht eingeschaltet wird, wenn die Ampel eine Anforderung erkennt
--
function TrafficLight:addLightStructure(redStructure, greenStructure, yellowStructure, requestStructure,
                                        housingStructure, blendStructure)
    local lightStructure = LightStructureTrafficLight:new(redStructure, greenStructure, yellowStructure,
                                                          requestStructure, housingStructure, blendStructure)
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

--- Aktualisiert den Text f¸r die aktuelle Phase dieses Signalgebers
-- @param phaseInfo TippText f¸r die Phase
--
function TrafficLight:setPhaseInfo(phaseInfo) self.phaseInfo = phaseInfo end

--- Aktualsisiert den Text f¸r die Fahrspuren dieser Ampel
-- @param laneInfo TippText f¸r die Fahrspur
--
function TrafficLight:setLaneInfo(laneInfo) self.laneInfo = laneInfo end

--- Aktualsisiert den Namen fuer die Fahrspur dieser Ampel
-- @param laneNameInfo TippText fuer den Fahrspurnamen
--
function TrafficLight:setLaneNameInfo(laneNameInfo) self.laneNameInfo = laneNameInfo end

local function shortTippName(name)
    return name and string.match(name, "^([^_]+)") or nil
end

local function tippTextStructure(lightStructure)
    return lightStructure.housingStructure or lightStructure.redStructure
end

local function addStructureName(structures, knownStructures, structureName)
    if structureName and not knownStructures[structureName] then
        table.insert(structures, structureName)
        knownStructures[structureName] = true
    end
end

local function allTippTextStructures(lightStructure)
    local structures = {}
    local knownStructures = {}
    addStructureName(structures, knownStructures, lightStructure.housingStructure)
    addStructureName(structures, knownStructures, lightStructure.redStructure)
    addStructureName(structures, knownStructures, lightStructure.greenStructure)
    addStructureName(structures, knownStructures, lightStructure.yellowStructure)
    addStructureName(structures, knownStructures, lightStructure.requestStructure)
    addStructureName(structures, knownStructures, lightStructure.blendStructure)
    return structures
end

function TrafficLight:showInfoText(showInfo)
    if self.signalId > 0 then
        Signal.showTippTextById(self.signalId, showInfo)
    else
        for l in pairs(self.lightStructures) do
            if showInfo then
                local structureName = tippTextStructure(l)
                if structureName then Structure.showTippTextByName(structureName, true) end
            else
                for _, structureName in ipairs(allTippTextStructures(l)) do
                    Structure.showTippTextByName(structureName, false)
                end
            end
        end
    end
end

function TrafficLight:changeInfoText(infoText)
    if self.signalId > 0 then
        Signal.setTippTextById(self.signalId, infoText)
    else
        for l in pairs(self.lightStructures) do
            if infoText == "" then
                for _, structureName in ipairs(allTippTextStructures(l)) do
                    Structure.setTippTextByName(structureName, "")
                end
            else
                local structureName = tippTextStructure(l)
                if structureName then Structure.setTippTextByName(structureName, infoText) end
            end
        end
    end
end

function TrafficLight:signalIdTippText()
    if self.signalId > 0 then return "Signal: " .. self.signalId end
    for l in pairs(self.lightStructures) do
        local structureName = tippTextStructure(l)
        if structureName then return "Immo: " .. shortTippName(structureName) end
    end
    return "Signal: " .. self.signalId
end

local function basename(value)
    return string.match(value:gsub("\\", "/"), "([^/]+)$") or value
end

local function withoutExtension(value)
    return string.gsub(value, "%.[^.]+$", "")
end

local function inferTrafficLightModelFromItemName(itemNameWithModelPath)
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

local function getSignalFunctionsTippText(signalId, trafficLightModel)
    if signalId > 0 and EEPGetSignalFunctions then
        local text = {}
        local found, trafficLightModelName = EEPGetSignalItemName(signalId, true)
        local effectiveTrafficLightModel = inferTrafficLightModelFromItemName(trafficLightModelName) or
            trafficLightModel
        if not found then return effectiveTrafficLightModel.name end
        table.insert(text, effectiveTrafficLightModel.name)
        table.insert(text, "<br>")
        table.insert(text, trafficLightModelName)
        local _, count = EEPGetSignalFunctions(signalId)
        for i = 1, count do
            local _, action = EEPGetSignalFunction(signalId, i)
            table.insert(text, "<br>")
            table.insert(text, EEPGetSignal(signalId) == i and "<b>" or "")
            table.insert(text, i)
            table.insert(text, ": ")
            table.insert(text, effectiveTrafficLightModel:indicationOf(i) or action)
            table.insert(text, EEPGetSignal(signalId) == i and "</b>." or ".")
        end
        return table.concat(text, "")
    else
        return trafficLightModel.name
    end
end

function TrafficLight:vehicleSignalNameTippText()
    local name = self.vehicleSignalName and "<b>" .. shortTippName(self.vehicleSignalName) .. "</b>" or ""
    local indication = self.currentIndication
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

function TrafficLight:pedestrianSignalNameTippText()
    local name = self.pedestrianSignalName and "<b>" .. shortTippName(self.pedestrianSignalName) .. "</b>" or ""
    local indication = self.currentIndication
    if indication == SignalIndication.PEDESTRIAN then
        return fmt.green(name)
    elseif indication == SignalIndication.OFF or indication == SignalIndication.OFF_BLINKING then
        return fmt.greyText(name)
    else
        return fmt.bgRed(name)
    end
end

function TrafficLight:signalNamesTippText()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then
        return self:pedestrianSignalNameTippText()
    elseif self.use == TrafficLight.Use.VEHICLE_AND_PEDESTRIAN then
        return self:vehicleSignalNameTippText() .. "<br>" .. self:pedestrianSignalNameTippText()
    else
        return self:vehicleSignalNameTippText()
    end
end

function TrafficLight:signalNamesText()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then
        return self.pedestrianSignalName or ""
    elseif self.use == TrafficLight.Use.VEHICLE_AND_PEDESTRIAN then
        return (self.vehicleSignalName or "") .. "/" .. (self.pedestrianSignalName or "")
    else
        return self.vehicleSignalName or ""
    end
end

--- Stellt die vorher gesetzten Tipp-Texte dar.
--
local function isPartOfSignalGroup(signal)
    return next(signal.signalGroupsByUse or {}) ~= nil
end

function TrafficLight:refreshInfo()
    local showPhase = IntersectionSettings.showPhaseOnSignal and self.phaseInfo and self.phaseInfo:len() > 0
    local showAllSignals = IntersectionSettings.showSignalIdOnSignal
    local showModelInfo = IntersectionSettings.showModelInfoOnSignal
    local showLaneName = IntersectionSettings.showLaneNamesOnSignal and self.laneNameInfo:len() > 0
    local showNameAndColor = IntersectionSettings.showNameAndPhaseOnSignal and
        (not self.isLaneSignal or isPartOfSignalGroup(self))
    local showRequests = IntersectionSettings.showRequestsOnSignal and self.laneInfo:len() > 0
    local showInfo = showAllSignals or showModelInfo or showLaneName or showNameAndColor or showRequests or showPhase

    self:showInfoText(showInfo)
    if showInfo then
        local infoText = "<j>"

        if showAllSignals then
            infoText = fmt.appendUpTo1023(infoText, self:signalIdTippText())
        end

        if showModelInfo then
            local signalFunctionsTippText = getSignalFunctionsTippText(self.signalId, self.trafficLightModel)
            if infoText ~= "<j>" then infoText = fmt.appendUpTo1023(infoText, "<br>") end
            infoText = fmt.appendUpTo1023(infoText, signalFunctionsTippText)
        end

        if showLaneName then
            if infoText ~= "<j>" then infoText = fmt.appendUpTo1023(infoText, "<br>") end
            infoText = fmt.appendUpTo1023(infoText, self.laneNameInfo)
        end

        if showNameAndColor and self.currentIndication then
            if infoText ~= "<j>" then infoText = fmt.appendUpTo1023(infoText, "<br>") end
            infoText = fmt.appendUpTo1023(infoText, self:signalNamesTippText())
        end

        if showRequests then
            if infoText ~= "<j>" then infoText = fmt.appendUpTo1023(infoText, "<br>") end
            infoText = fmt.appendUpTo1023(infoText, self.laneInfo)
        end

        if showPhase and self.phaseInfo then
            infoText = fmt.appendUpTo1023(infoText, "<br><br><b>" .. "Phase: " .. "</b>")
            infoText = fmt.appendUpTo1023(infoText, self.phaseInfo)
        end

        if showPhase and not showNameAndColor and self.currentIndication and self.reason then
            infoText = fmt.appendUpTo1023(infoText, "<br><br>")
            infoText = fmt.appendUpTo1023(infoText, string.format(" %s (%s) ", self.currentIndication, self.reason))
        end

        self:changeInfoText(infoText)
    elseif self.signalId < 0 and next(self.lightStructures) ~= nil then
        self:changeInfoText("")
    end
end

function TrafficLight.switchAll(signals, indication, reason)
    for signal in pairs(signals) do signal:switchTo(indication, reason) end
end

---
-- @param signalId ID der Ampel auf der Anlage (Eine Ampel von diesem Typ sollte auf der Anlage sein)
-- @param indication SignalIndication.xxx
-- @param reason z.B. Name der Phase
--
function TrafficLight:switchTo(indication, reason)
    assert(type(indication) == "string", "Need 'indication' as string")
    self.currentIndication = indication
    self.reason = reason
    local lightDbg = self:switchStructureLight()
    local axisDbg = self:switchStructureAxis()

    local sigIndex = self.trafficLightModel:signalIndexOf(self.currentIndication)
    if (self.debug or TrafficLight.debug) then
        print(string.format(
            "[TrafficLight    ] Schalte Ampel %04d auf %s (%01d)%s%s - %s",
            self.signalId,
            self.currentIndication,
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
            local onOff = self.currentIndication == SignalIndication.RED or
                self.currentIndication == SignalIndication.REDYELLOW
            lightDbg = lightDbg .. string.format(", Licht in %s: %s", lightTL.redStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.redStructure, onOff)
        end
        if lightTL.yellowStructure then
            local onOff = self.currentIndication == SignalIndication.YELLOW or
                self.currentIndication == SignalIndication.REDYELLOW
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.yellowStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.yellowStructure, onOff)
        end
        if lightTL.greenStructure then
            local onOff = self.currentIndication == SignalIndication.GREEN
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.greenStructure, onOff and "an" or "aus")
            EEPStructureSetLight(lightTL.greenStructure, onOff)
        end
    end
    return lightDbg
end

function TrafficLight:switchStructureAxis()
    local axisDbg = ""
    for axisTL in pairs(self.axisStructures) do
        local position = axisTL.positionDefault

        if axisTL.positionRedYellow and self.currentIndication == SignalIndication.REDYELLOW then
            position = axisTL.positionRedYellow
        elseif axisTL.positionRed and
            (self.currentIndication == SignalIndication.YELLOW or
                self.currentIndication == SignalIndication.REDYELLOW) then
            position = axisTL.positionRed
        elseif axisTL.positionRed and self.currentIndication == SignalIndication.RED then
            position = axisTL.positionRed
        elseif axisTL.positionGreen and self.currentIndication == SignalIndication.GREEN then
            position = axisTL.positionGreen
        elseif axisTL.positionPedestrian and self.currentIndication == SignalIndication.PEDESTRIAN then
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
        self.currentIndication,
        self.trafficLightModel.name
    ))
end

function TrafficLight:changed() for lane in pairs(self.lanes) do lane:signalChanged(self) end end

---@param lane Lane The lane apply this signal for
function TrafficLight:applyToLane(lane, ...)
    lane:driveOn(self, ...)
    local laneSignal = lane.laneSignal
    if self ~= laneSignal then laneSignal.lanes[lane] = nil end
    self.lanes[lane] = true
end

return TrafficLight
