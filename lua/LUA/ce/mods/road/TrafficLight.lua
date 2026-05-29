if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficLight ...") end

---@class TrafficLight
---@field Use table<string, string>
---@field type string
---@field vehicleSignalName string|nil
---@field pedestrianSignalName string|nil
---@field use string
---@field signalId number
---@field trafficLightModel TrafficLightModel
---@field currentIndication string
---@field lightStructures table
---@field axisStructures table
---@field reason string
---@field lanes table
---@field signalGroupsByUse table<string, SignalGroup>|nil
---@field debug boolean
---@field buildInfo string
---@field getAll fun():TrafficLight[]
---@field getSignalId fun(self: TrafficLight):number
---@field getVehicleSignalName fun(self: TrafficLight):string|nil
---@field getPedestrianSignalName fun(self: TrafficLight):string|nil
---@field getUse fun(self: TrafficLight):string
---@field getTrafficLightModel fun(self: TrafficLight):TrafficLightModel
---@field getCurrentIndication fun(self: TrafficLight):string
---@field getReason fun(self: TrafficLight):string|nil
---@field getSignalGroupsByUse fun(self: TrafficLight):table<string, SignalGroup>
---@field getPrimaryTippTextStructure fun(self: TrafficLight):string|nil
---@field getPrimaryTippTextStructures fun(self: TrafficLight):string[]
---@field getAllTippTextStructures fun(self: TrafficLight):string[]
---@field newForSignal fun(self: TrafficLight, name: string, signalId: number,
--- trafficLightModel: TrafficLightModel, redStructure?: string, greenStructure?: string,
--- yellowStructure?: string, requestStructure?: string, housingStructure?: string,
--- blendStructure?: string):TrafficLight
---@field new fun(self: TrafficLight, name: string, signalId: number, trafficLightModel: TrafficLightModel,
--- redStructure?: string, greenStructure?: string, yellowStructure?: string, requestStructure?: string,
--- housingStructure?: string, blendStructure?: string):TrafficLight
---@field newPedestrianOnly fun(self: TrafficLight, name: string, signalId: number,
--- trafficLightModel: TrafficLightModel, redStructure?: string, greenStructure?: string,
--- yellowStructure?: string, requestStructure?: string, housingStructure?: string,
--- blendStructure?: string):TrafficLight
---@field newForLightStructure fun(self: TrafficLight, name: string, redStructure?: string,
--- greenStructure?: string, yellowStructure?: string, requestStructure?: string, housingStructure?: string,
--- blendStructure?: string):TrafficLight
---@field asPedestrianSignal fun(self: TrafficLight, pedestrianSignalName: string):TrafficLight
---@field withPedestrian fun(self: TrafficLight, pedestrianSignalName: string):TrafficLight
---@field asPedestrianOnly fun(self: TrafficLight):TrafficLight
---@field signalNamesText fun(self: TrafficLight):string
---@field addLightStructure fun(self: TrafficLight, redStructure?: string, greenStructure?: string,
--- yellowStructure?: string, requestStructure?: string, housingStructure?: string,
--- blendStructure?: string):TrafficLight
---@field addAxisStructure fun(self: TrafficLight, structureName: string, axisName: string, positionDefault: number,
--- positionRed?: number, positionGreen?: number, positionYellow?: number,
--- positionRedYellow?: number, positionPedestrian?: number):TrafficLight
---@field switchAll fun(signals: table, indication: string, reason?: string):nil
---@field switchTo fun(self: TrafficLight, indication: string, reason?: string):nil
---@field switchStructureLight fun(self: TrafficLight):string
---@field switchStructureAxis fun(self: TrafficLight):string
---@field switchSignal fun(self: TrafficLight, sigIndex: number):nil
---@field showRequestOnSignal fun(self: TrafficLight, hasRequest: boolean):nil
---@field print fun(self: TrafficLight):nil
---@field changed fun(self: TrafficLight):nil
---@field applyToLane fun(self: TrafficLight, lane: Lane, ...: string):nil

---@alias SignalHead TrafficLight

local AxisStructureTrafficLight = require("ce.mods.road.AxisStructureTrafficLight")
local LightStructureTrafficLight = require("ce.mods.road.LightStructureTrafficLight")
local SignalIndication = require("ce.mods.road.SignalIndication")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

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
local allTrafficLights = {}
local counter = -1
function TrafficLight.getAll()
    local copy = {}
    for i, signal in ipairs(allTrafficLights) do copy[i] = signal end
    return copy
end


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
    if signalId < 0 then counter = counter - 1 end
    local o = {
        vehicleSignalName = name,
        pedestrianSignalName = nil,
        use = TrafficLight.Use.VEHICLE_ONLY,
        signalId = signalId > 0 and signalId or counter,
        trafficLightModel = trafficLightModel,
        currentIndication = signalId > 0 and
            trafficLightModel:indicationOf(SignalRegistry.getOrCreate(signalId):pullPosition() or
                                           trafficLightModel.signalIndexRed) or
            SignalIndication.RED,
        debug = false,
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
    table.insert(allTrafficLights, o)
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
    if self.pedestrianSignalName == pedestrianSignalName and self.use == TrafficLight.Use.VEHICLE_AND_PEDESTRIAN then
        return self
    end
    self.pedestrianSignalName = pedestrianSignalName
    self.use = TrafficLight.Use.VEHICLE_AND_PEDESTRIAN
    return self
end

function TrafficLight:withPedestrian(pedestrianSignalName) return self:asPedestrianSignal(pedestrianSignalName) end

function TrafficLight:asPedestrianOnly()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then return self end
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

function TrafficLight:getSignalId() return self.signalId end

function TrafficLight:getVehicleSignalName() return self.vehicleSignalName end

function TrafficLight:getPedestrianSignalName() return self.pedestrianSignalName end

function TrafficLight:getUse() return self.use end

function TrafficLight:getTrafficLightModel() return self.trafficLightModel end

function TrafficLight:getCurrentIndication() return self.currentIndication end

function TrafficLight:getReason() return self.reason end

function TrafficLight:getSignalGroupsByUse() return self.signalGroupsByUse or {} end

function TrafficLight:signalNamesText()
    if self.use == TrafficLight.Use.PEDESTRIAN_ONLY then
        return self.pedestrianSignalName or ""
    elseif self.use == TrafficLight.Use.VEHICLE_AND_PEDESTRIAN then
        return (self.vehicleSignalName or "") .. "/" .. (self.pedestrianSignalName or "")
    else
        return self.vehicleSignalName or ""
    end
end

function TrafficLight:getPrimaryTippTextStructure()
    for lightStructure in pairs(self.lightStructures) do
        local structureName = tippTextStructure(lightStructure)
        if structureName then return structureName end
    end
    return nil
end

function TrafficLight:getPrimaryTippTextStructures()
    local structures = {}
    local knownStructures = {}
    for lightStructure in pairs(self.lightStructures) do
        addStructureName(structures, knownStructures, tippTextStructure(lightStructure))
    end
    return structures
end

function TrafficLight:getAllTippTextStructures()
    local structures = {}
    local knownStructures = {}
    for lightStructure in pairs(self.lightStructures) do
        for _, structureName in ipairs(allTippTextStructures(lightStructure)) do
            addStructureName(structures, knownStructures, structureName)
        end
    end
    return structures
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
            StructureRegistry.getOrCreate(lightTL.redStructure):setLight(onOff)
        end
        if lightTL.yellowStructure then
            local onOff = self.currentIndication == SignalIndication.YELLOW or
                self.currentIndication == SignalIndication.REDYELLOW
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.yellowStructure, onOff and "an" or "aus")
            StructureRegistry.getOrCreate(lightTL.yellowStructure):setLight(onOff)
        end
        if lightTL.greenStructure then
            local onOff = self.currentIndication == SignalIndication.GREEN
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.greenStructure, onOff and "an" or "aus")
            StructureRegistry.getOrCreate(lightTL.greenStructure):setLight(onOff)
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
        StructureRegistry.getOrCreate(axisTL.structureName):setAxis(axisTL.axisName, position)
    end
    return axisDbg
end

function TrafficLight:switchSignal(sigIndex)
    if self.signalId > 0 then SignalRegistry.getOrCreate(self.signalId):setPosition(sigIndex) end
end

--- Setzt die Anforderung fuer eine Ampel (damit sie weiﬂ, ob eine Anforderung vorliegt)
--- @param hasRequest boolean wo liegt die Anforderung an
function TrafficLight:showRequestOnSignal(hasRequest)
    local lightDbg = ""

    for lightTL in pairs(self.lightStructures) do
        if lightTL.requestStructure then
            lightDbg = lightDbg ..
                string.format(", Licht in %s: %s", lightTL.requestStructure, (hasRequest) and "an" or "aus")
            StructureRegistry.getOrCreate(lightTL.requestStructure):setLight(hasRequest)
        end
    end

    if (self.debug or TrafficLight.debug) and lightDbg ~= "" then
        print(string.format("[TrafficLight    ] Schalte Ampel %04d%s", self.signalId, lightDbg))
    end
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
