if CeDebugLoad then print("[#Start] Loading ce.mods.road.Lane ...") end

local Queue = require("ce.hub.util.Queue")
local StorageUtility = require("ce.hub.util.StorageUtility")
local TrafficLightState = require("ce.mods.road.TrafficLightState")
local fmt = require("ce.hub.eep.TippTextFormatter")

-- Lane starts here
local Lane = {}
Lane.debug = CeStartWithDebug or false
local RouteDriveMode = { ONLY = "ONLY", ALSO = "ALSO" }
local ROUTE_WILDCARD = "!ALL!"

---@type table<string, LaneRequestType>
Lane.RequestType = {
    NICHT_VERWENDET = "NICHT VERWENDET",
    ANFORDERUNG = "ANFORDERUNG",
    NORMAL = "NORMAL",
    FUSSGAENGER = "FUSSGAENGER"
}
---@type table<string, LaneDirection>
Lane.Directions = {
    LEFT = "LEFT",
    HALF_LEFT = "HALF-LEFT",
    STRAIGHT = "STRAIGHT",
    HALF_RIGHT = "HALF-RIGHT",
    RIGHT = "RIGHT"
}
---@type table<string, LaneType>
Lane.Type = { BUS = "BUS", CAR = "CAR", TRAM = "TRAM", PEDESTRIAN = "PEDESTRIAN", BICYCLE = "BICYCLE" }

---Liefert true, wenn das erste Fahrzeug fahren darf (anhand der für die Fahrspur gültigen Ampeln)
---Is true, if the first vehicle can drive (according to the lane's traffic lights)
local function updateLaneSignal(lane, reason)
    if lane.trafficLightsToDriveOn then
        if not lane.queue:isEmpty() then assert(lane.firstVehiclesRoute) end

        local haveGreen = false
        local greenTrafficLights = {}
        for trafficLight in pairs(lane.trafficLightsToDriveOn) do
            if Lane.debug then
                print(string.format(
                    "[#Lane] %s can drive on: %s (%s): %s",
                    lane.name,
                    trafficLight:signalNamesText(),
                    trafficLight.phase,
                    tostring(TrafficLightState.canDrive(trafficLight.phase))
                ))
            end
            if TrafficLightState.canDrive(trafficLight.phase) then
                haveGreen = true
                table.insert(greenTrafficLights, trafficLight)
            end
        end

        local canDrive
        if haveGreen then
            canDrive = Lane.laneCanDrive(lane, greenTrafficLights)
        else
            canDrive = false
        end
        lane.laneTrafficLight:switchTo(canDrive and TrafficLightState.GREEN or TrafficLightState.RED, reason)
    end
end

-- Might bring some performance
local EEPGetTrainRoute = EEPGetTrainRoute
local EEPRegisterRoadTrack = EEPRegisterRoadTrack
local EEPIsRoadTrackReserved = EEPIsRoadTrackReserved
local EEPGetSignalTrainsCount = EEPGetSignalTrainsCount
local EEPGetSignalTrainName = EEPGetSignalTrainName

---If trainname is provided, this function will add the train to the lane's queue
---@param lane Lane the current lane, where the correction will take place
---@param trainName string Name of the train
local function addTrainToQueue(lane, trainName)
    assert(not trainName:find(","), trainName)
    assert(not trainName:find("|"), trainName)

    if trainName and not lane.signalUsedForRequest then
        lane.queue:push(trainName)

        -- Remember the "first good vehicle"
        lane.firstGoodTrain = lane.firstGoodTrain or trainName

        -- Fix queue length
        if lane.vehicleCount ~= lane.queue:size() then
            print(string.format(
                "[#Lane] AUTOCORRECT %s: New vehicle count from queue length: %d; Current count: %d",
                lane.name,
                lane.queue:size(),
                lane.vehicleCount
            ))
            lane.vehicleCount = lane.queue:size()
        end
    end
    if lane.queue:size() == 1 then
        local _, route = EEPGetTrainRoute(lane.queue:firstElement())
        lane.firstVehiclesRoute = route
    end
end

---If trainname is provided, this function will remove the trains from the lane's queue
---@param lane Lane the current lane, where the correction will take place
---@param trainName string Name of the train
local function popTrainFromQueue(lane, trainName)
    if trainName and not lane.signalUsedForRequest then
        if trainName == lane.firstGoodTrain then lane.firstGoodTrain = nil end

        local numberOfPops = lane.queue:size()
        for i, trainFromQueue in pairs(lane.queue:elements()) do
            if trainFromQueue == trainName then
                numberOfPops = i
                break
            end

            if trainFromQueue == lane.firstGoodTrain then
                numberOfPops = i - 1
                break
            end
        end

        -- Remove train and fix queue
        if numberOfPops > 1 and Lane.debug then
            print(string.format(
                "[#Lane] AUTOCORRECT %s: Have to remove %d trains to get to %s",
                lane.name,
                numberOfPops,
                trainName
            ))
        end
        for _ = 1, numberOfPops, 1 do
            local trainFromQueue = lane.queue:pop()
            if Lane.debug and trainFromQueue ~= trainName then
                print(string.format("[#Lane] AUTOCORRECT %s: Removed additional train %s", lane.name, trainFromQueue))
            end
        end

        -- Fix queue length
        if lane.vehicleCount ~= lane.queue:size() then
            if Lane.debug and numberOfPops == 1 then
                print(string.format(
                    "[#Lane] AUTOCORRECT %s: New vehicle count from queue length: %d; Current count: %d",
                    lane.name,
                    lane.queue:size(),
                    lane.vehicleCount
                ))
            end
            lane.vehicleCount = lane.queue:size()
        end
    end
    if not lane.queue:isEmpty() then
        local _, route = EEPGetTrainRoute(lane.queue:firstElement())
        lane.firstVehiclesRoute = route
    else
        lane.firstVehiclesRoute = "NO VEHICLE"
    end
end
local function queueToText(queue) return table.concat(queue:elements(), "|") end

local function queueFromText(pipeSeparatedText, count)
    local queue = Queue:new()
    if pipeSeparatedText then
        for trainName in string.gmatch(pipeSeparatedText, "[^|]+") do
            -- print("[#Lane] " .. trainName)
            queue:push(trainName)
        end
    else
        -- For compatibility with old versions, we fill with generic names
        for i = 1, count, 1 do queue:push("train " .. i) end
    end
    return queue
end

local function save(lane)
    if lane.eepSaveId ~= -1 then
        local data = {}
        data["f"] = tostring(lane.vehicleCount)
        data["w"] = tostring(lane.waitCount)
        data["p"] = tostring(lane.phase)
        data["q"] = queueToText(lane.queue)
        StorageUtility.saveTable(lane.eepSaveId, data, "Lane " .. lane.name)
    end
end

local function load(lane)
    if lane.eepSaveId ~= -1 then
        local data = StorageUtility.loadTable(lane.eepSaveId, "Lane " .. lane.name)
        lane.vehicleCount = data["f"] and tonumber(data["f"]) or 0
        lane.waitCount = data["w"] and tonumber(data["w"]) or 0
        lane.phase = data["p"] or TrafficLightState.RED
        lane.queue = queueFromText(data["q"], lane.vehicleCount)
        lane:checkRequests()
        updateLaneSignal(lane, "Neu geladen")
    else
        lane.vehicleCount = 0
        lane.waitCount = 0
        lane.phase = TrafficLightState.RED
        lane.queue = Queue:new()
        lane:checkRequests()
        updateLaneSignal(lane, "Neu geladen")
    end

    if not lane.queue:isEmpty() then
        local _, route = EEPGetTrainRoute(lane.queue:firstElement())
        lane.firstVehiclesRoute = route
    end
end

local function refreshRequests(lane)
    if lane.requestTrafficLights then
        ---@type Queue
        local queue = lane.queue
        local queuedRoutes = {}
        local hasDefaultRouteRequest = false
        local carsInQueue = not queue:isEmpty()
        for _, car in ipairs(queue:elements()) do
            local _, route = EEPGetTrainRoute(car)
            queuedRoutes[route] = true
            local routeRules = Lane.effectiveRouteDriveRules(lane, route)
            if not (routeRules and routeRules[RouteDriveMode.ONLY]) then hasDefaultRouteRequest = true end
        end

        local requests = {}
        for route, trafficLights in pairs(lane.requestTrafficLights) do
            local wildCardRoute = route == ROUTE_WILDCARD
            local haveRequest = queuedRoutes[route] or (wildCardRoute and carsInQueue and hasDefaultRouteRequest)
            for _, trafficLight in ipairs(trafficLights) do
                if not requests[trafficLight] then requests[trafficLight] = haveRequest end
            end
        end
        for trafficLight, haveRequest in pairs(requests) do trafficLight:showRequestOnSignal(haveRequest) end
    end
end

function Lane.effectiveRouteDriveRules(lane, route)
    return lane.routeDriveRules and lane.routeDriveRules[route]
end

function Lane.laneCanDrive(lane, trafficLights)
    if lane.trafficLightsToDriveOn then
        local trafficLightsSet = {}
        for _, trafficLight in ipairs(trafficLights) do trafficLightsSet[trafficLight] = true end
        local routeRules = Lane.effectiveRouteDriveRules(lane, lane.firstVehiclesRoute)
        if routeRules and routeRules[RouteDriveMode.ONLY] then
            for trafficLight in pairs(routeRules[RouteDriveMode.ONLY]) do
                if trafficLightsSet[trafficLight] then return true end
            end
            return false
        end
        if lane.defaultDriveTrafficLights then
            for trafficLight in pairs(lane.defaultDriveTrafficLights) do
                if trafficLightsSet[trafficLight] then return true end
            end
        end
        if routeRules and routeRules[RouteDriveMode.ALSO] then
            for trafficLight in pairs(routeRules[RouteDriveMode.ALSO]) do
                if trafficLightsSet[trafficLight] then return true end
            end
        end
        return false
    else
        -- In case, there is no couting, we need to return true
        return true
    end
end
--------------------
-- Klasse Fahrspur
--------------------
function Lane.getType() return "Lane" end

function Lane:getName() return self.name end

function Lane:getLaneType() return self.requestType end

function Lane:setLaneType(requestType)
    assert(requestType)
    assert(self.requestType == Lane.RequestType.NICHT_VERWENDET or self.requestType == requestType,
           "Diese Fahrspur hatte schon den Schaltungstyp: '" .. self.requestType .. "' und kann daher nicht auf '" ..
           requestType .. "' gesetzt werden.")
    self.requestType = requestType
end

function Lane:getVehicleCountRoutes(routes)
    local count = 0
    if #routes == 0 then
        count = self.vehicleCount
    else
        for i, vehicleName in pairs(self.queue:elements()) do
            local _, trainRoute = EEPGetTrainRoute(vehicleName)
            local routeMatches = false
            for _, route in pairs(routes) do
                if route == trainRoute then
                    routeMatches = true
                    break
                end
            end

            if not routeMatches then
                count = i
                break
            end
        end
    end
    return count
end

function Lane:checkRequests()
    if self.signalUsedForRequest == true then
        self:resetQueueFromSignal()
    elseif self.tracksUsedForRequest == true then
        self:resetQueueFromRoadTracks()
    end

    local text = ""
    if self.requestType == Lane.RequestType.NORMAL then
        text = text .. fmt.bgGreen(self.name)
    elseif self.requestType == Lane.RequestType.FUSSGAENGER then
        text = text .. fmt.bgYellow(self.name)
    elseif self.requestType == Lane.RequestType.ANFORDERUNG then
        text = text .. fmt.bgBlue(self.name)
    else
        text = text .. fmt.red(self.name)
    end

    text = text .. ": " .. (not self.queue:isEmpty() and fmt.lightGrey("BELEGT") or fmt.lightGrey("-FREI-")) .. " "
    if self.tracksUsedForRequest then
        text = text .. "(Strasse)"
    elseif self.signalUsedForRequest then
        text = text .. "(Ampel)"
    else
        text = text .. "(" .. self.vehicleCount .. " gezaehlt)"
    end

    for _, vehicle in ipairs(self.queue:elements()) do text = text .. "<br>" .. vehicle end

    self.requestInfoText = text
    refreshRequests(self)
end

function Lane:calculatePriority(trafficLights)
    if Lane.laneCanDrive(self, trafficLights) then
        local vehicleCount = self.queue:size()
        local prio = vehicleCount * 3 * self.fahrzeugMultiplikator
        return self.waitCount > prio and self.waitCount or prio
    else
        return self.waitCount
    end
end

function Lane:getRequestInfo() return self.requestInfoText or "KEINE ANFORDERUNG" end

---@param roadId number Road Track ID
function Lane:useTrackForQueue(roadId)
    assert(not self.signalUsedForRequest, "CANNOT COUNT ON SIGNALS AND TRACKS")
    self.tracksUsedForRequest = true
    EEPRegisterRoadTrack(roadId)
    if not self.tracksForRequests[roadId] then self.tracksForRequests[roadId] = true end
    return self
end

function Lane:resetQueueFromRoadTracks()
    for _ = 1, self.queue:size(), 1 do self.queue:pop() end
    for strassenId in pairs(self.tracksForRequests) do
        local ok, waiting, trainName = EEPIsRoadTrackReserved(strassenId, true)
        assert(ok)

        if waiting then
            if not trainName then print(string.format("[#Lane] Kein Zug auf Strasse: %s", strassenId)) end
            assert(trainName)
            self.queue:push(trainName)
        end
    end
    save(self)
end

function Lane:showRequestsOn(trafficLight, ...)
    assert(self and self.getType and "function" == type(self.getType) and self.getType() == "Lane",
           "Did you use colons instead of a dot myLane:showRequestsOn(...)")
    local routes = ... and { ... } or { ROUTE_WILDCARD }
    self.requestTrafficLights = self.requestTrafficLights or {}
    for _, route in ipairs(routes) do
        self.requestTrafficLights[route] = self.requestTrafficLights[route] or {}
        table.insert(self.requestTrafficLights[route], trafficLight)
    end
end
local RouteDriveBuilder = {}
local function ensureTrafficLightCanDrive(lane, trafficLight)
    assert(trafficLight.type == "TrafficLight")
    lane.trafficLightsToDriveOn = lane.trafficLightsToDriveOn or {}
    lane.trafficLightsToDriveOn[trafficLight] = lane.trafficLightsToDriveOn[trafficLight] or {}
    trafficLight.lanes[lane] = true
    if trafficLight ~= lane.laneTrafficLight then lane.laneTrafficLight.lanes[lane] = nil end
end
local function routeList(...)
    local routes = { ... }
    assert(#routes > 0, "Specify at least one route")
    for _, route in ipairs(routes) do assert(type(route) == "string", "Need 'route' as string") end
    return routes
end
local function ensureRouteRule(lane, route, mode)
    lane.routeDriveRules = lane.routeDriveRules or {}
    lane.routeDriveRules[route] = lane.routeDriveRules[route] or {}
    lane.routeDriveRules[route][mode] = lane.routeDriveRules[route][mode] or {}
    return lane.routeDriveRules[route][mode]
end
local function appendRoutesForTrafficLight(lane, trafficLight, routes)
    local configuredRoutes = lane.trafficLightsToDriveOn[trafficLight]
    for _, route in ipairs(routes) do
        local known = false
        for _, configuredRoute in ipairs(configuredRoutes) do
            if route == configuredRoute then
                known = true
                break
            end
        end
        if not known then table.insert(configuredRoutes, route) end
    end
end
local function routeBuilderDriveOn(builder, trafficLight, mode)
    local lane = builder.lane
    ensureTrafficLightCanDrive(lane, trafficLight)
    appendRoutesForTrafficLight(lane, trafficLight, builder.selectedRoutes)
    for _, route in ipairs(builder.selectedRoutes) do ensureRouteRule(lane, route, mode)[trafficLight] = true end
    return builder
end
local function routeBuilderDriveOnAll(builder, mode, ...)
    local trafficLights = { ... }
    assert(#trafficLights > 0, "Specify at least one traffic light")
    for _, trafficLight in ipairs(trafficLights) do routeBuilderDriveOn(builder, trafficLight, mode) end
    return builder
end
function RouteDriveBuilder:driveOnlyOn(...)
    return routeBuilderDriveOnAll(self, RouteDriveMode.ONLY, ...)
end
function RouteDriveBuilder:driveAlsoOn(...)
    return routeBuilderDriveOnAll(self, RouteDriveMode.ALSO, ...)
end
function RouteDriveBuilder:showRequestsOn(...)
    for _, trafficLight in ipairs({ ... }) do
        self.lane:showRequestsOn(trafficLight, table.unpack(self.selectedRoutes))
    end
    return self.lane
end
---Z?hle alle Fahrzeuge am Signal
---Count on the lane's traffic signal
function Lane:useSignalForQueue()
    assert(not self.tracksUsedForRequest, "CANNOT COUNT ON SIGNALS AND TRACKS")
    self.signalUsedForRequest = true
    return self
end

function Lane:resetQueueFromSignal()
    for _ = 1, self.queue:size(), 1 do self.queue:pop() end

    local wartend = EEPGetSignalTrainsCount(self.laneTrafficLight.signalId)
    for i = 1, wartend, 1 do
        local trainName = EEPGetSignalTrainName(self.laneTrafficLight.signalId, i)
        self.queue:push(trainName)
    end
    save(self)
end

--- Das Fahrzeug "vehicle" hat die Fahrspur betreten --> Rufe diese Funktion vom Kontaktpunkt aus auf
--- The vehicle entered this lane -> call this in a contact point
---@param trainName string name of the vehicle, i.e. train name in EEP
function Lane:vehicleEntered(trainName)
    self.vehicleCount = self.vehicleCount + 1
    addTrainToQueue(self, trainName)
    refreshRequests(self)
    updateLaneSignal(self, trainName .. " entered")
    save(self)
end

--- Das Fahrzeug "vehicle" hat die Fahrspur verlassen --> Rufe diese Funktion vom Kontaktpunkt aus auf
--- The vehicle left this lane -> call this in a contact point
---@param trainName string name of the vehicle, i.e. train name in EEP
function Lane:vehicleLeft(trainName)
    self.vehicleCount = self.vehicleCount > 0 and self.vehicleCount - 1 or 0
    popTrainFromQueue(self, trainName)
    refreshRequests(self)
    updateLaneSignal(self, trainName .. " left")
    save(self)
end

function Lane:resetVehicles()
    assert(self and self.type == "Lane")
    while not self.queue:isEmpty() do self.queue:pop() end
    self.vehicleCount = 0
    refreshRequests(self)
    updateLaneSignal(self, "Vehicles resetted")
    save(self)
end

function Lane:incrementWaitCount()
    self.waitCount = self.waitCount + 1
    save(self)
end

function Lane:resetWaitCount()
    self.waitCount = 0
    save(self)
end

function Lane:hasRequest() return not self.queue:isEmpty() end

function Lane:getWaitCount() return self.waitCount end

function Lane:getVehicleCount() return self.vehicleCount end

function Lane:setFahrzeugMultiplikator(fahrzeugMultiplikator)
    self.fahrzeugMultiplikator = fahrzeugMultiplikator
    return self
end

function Lane:switchTrafficLightTo(phase, grund)
    self.laneTrafficLight:switchTo(phase, grund)
    self.phase = phase
end

function Lane:setHighLightingTracks(...)
    for _, track in ipairs({ ... }) do assert(type(track) == "number", "Provide tracks as numbers") end

    self.tracksForHighlighting = { ... } or {}
    return self
end

function Lane:setDirections(...)
    for _, direction in pairs(...) do
        if not Lane.Directions[direction] then print(string.format("[#Lane] No such direction: %s", direction)) end
    end

    self.directions = ... or { "LEFT", "STRAIGHT", "RIGHT" }
end

function Lane:setTrafficType(trafficType)
    if not Lane.Type[trafficType] then
        print(string.format("[#Lane] No such traffic type: %s", trafficType))
    else
        self.trafficType = trafficType
    end
end

--- Erzeugt eine Fahrspur, welche durch genau ein EEP-Fahrspur-Signal gesteuert wird.
---@param name string @Name der Fahrspur einer Kreuzung
---@param eepSaveId number, @EEPSaveSlot-Id fuer das Speichern der Fahrspur
---@param laneTrafficLight TrafficLight @das einzelne EEP-Fahrspur-Signal, das Fahrzeuge anhaelt oder freigibt
---@param directions? string[] eine oder mehrere Ampeln
---@param trafficType? string (default: "NORMAL")
---@return Lane
function Lane:new(name, eepSaveId, laneTrafficLight, directions, trafficType)
    assert(name, "Bitte geben Sie den Namen \"name\" fuer diese Fahrspur an.")
    assert(type(name) == "string", "Need 'name' as string")
    assert(eepSaveId, "Bitte geben Sie den Wert \"eepSaveId\" fuer diese Fahrspur an.")
    assert(type(eepSaveId) == "number")
    assert(laneTrafficLight,
           "Specify a single \"laneTrafficLight\" for this lane (the EEP signal controlling the lane traffic).")
    assert(laneTrafficLight.type == "TrafficLight",
           "Specify a single \"laneTrafficLight\" for this lane (the EEP signal controlling the lane traffic).")
    -- assert(signalId, "Bitte geben Sie den Wert \"signalId\" fuer diese Fahrspur an.")
    if eepSaveId ~= -1 then StorageUtility.registerId(eepSaveId, "Lane " .. name) end
    local o = {
        name = name,
        type = "Lane",
        eepSaveId = eepSaveId,
        laneTrafficLight = laneTrafficLight,
        trafficLight = laneTrafficLight,
        requestType = Lane.RequestType.NORMAL,
        routesToCount = {},
        signalUsedForRequest = false,
        tracksUsedForRequest = false,
        tracksForRequests = {},
        directions = directions or { "LEFT", "STRAIGHT", "RIGHT" },
        trafficType = trafficType or "NORMAL",
        vehicleCount = 0,
        fahrzeugMultiplikator = 1,
        activeLaneSettings = nil
    }

    self.__index = self
    setmetatable(o, self)
    laneTrafficLight:applyToLane(o)
    load(o)
    return o
end

---Sets the default traffic lights which allow this lane to drive.
---@param ... TrafficLight
function Lane:driveOnDefaultSignals(...)
    local trafficLights = { ... }
    assert(#trafficLights > 0, "Specify at least one traffic light")

    local newDefaultDriveTrafficLights = {}
    for _, trafficLight in ipairs(trafficLights) do
        ensureTrafficLightCanDrive(self, trafficLight)
        newDefaultDriveTrafficLights[trafficLight] = true
    end

    if self.defaultDriveTrafficLights then
        for trafficLight in pairs(self.defaultDriveTrafficLights) do
            if not newDefaultDriveTrafficLights[trafficLight] then
                self.trafficLightsToDriveOn[trafficLight] = nil
                if trafficLight ~= self.laneTrafficLight then trafficLight.lanes[self] = nil end
            end
        end
    end

    self.defaultDriveTrafficLights = newDefaultDriveTrafficLights
    for trafficLight in pairs(newDefaultDriveTrafficLights) do self.trafficLightsToDriveOn[trafficLight] = {} end
    return self
end

---Starts a route-bound drive signal registration.
---@param ... string Route names
function Lane:routes(...)
    return setmetatable({ lane = self, selectedRoutes = routeList(...) }, { __index = RouteDriveBuilder })
end

---Fuegt eine Ampel hinzu nach deren Gruen (oder Aus!) gefahren werden darf.
---Ohne Routen wird sie als Standardsignal registriert, mit Routen als zusaetzliches Routensignal.
---
---Sets the traffic light which is used to drive.
---Without routes it is registered as default signal, with routes as additional route signal.
---@param trafficLight TrafficLight
function Lane:driveOn(trafficLight, ...)
    assert(trafficLight.type == "TrafficLight")
    if trafficLight == self.laneTrafficLight then return self end
    if ... then
        self:routes(...):driveAlsoOn(trafficLight)
    else
        self:driveOnDefaultSignals(trafficLight)
    end
    return self
end

---Called by the traffic light, if the traffic light changed
---This will update the internal signal by the canDrive method
---Wird von einer Ampel aufgerufen, dass über die driveOn() Methode für diese Fahrspur angemeldet wurde
---@param trafficLight TrafficLight
function Lane:trafficLightChanged(trafficLight)
    if trafficLight ~= self.laneTrafficLight then
        assert(self.trafficLightsToDriveOn, "There is no traffic light registered on this lane: " ..
            trafficLight.signalId .. " / " .. self.laneTrafficLight.signalId)
        assert(self.trafficLightsToDriveOn[trafficLight],
               "This lane does not drive on the given traffic light: " .. trafficLight.signalId)
    end
    self.phase = trafficLight.phase
    updateLaneSignal(self, "Traffic Light update: " .. trafficLight.signalId)
end

return Lane
