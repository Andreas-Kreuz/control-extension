if CeDebugLoad then print("[#Start] Loading ce.hub.eep.Anl3DiscoveryHelper ...") end

local ScenarioDiscovery = require("ce.hub.data.scenario.ScenarioDiscovery")
local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
local ContactDiscovery = require("ce.hub.data.contacts.ContactDiscovery")
local RouteDiscovery = require("ce.hub.data.routes.RouteDiscovery")
local StructureResourceParser = require("ce.hub.eep.StructureResourceParser")

local Anl3DiscoveryHelper = {}

local function findChild(node, tag)
    for _, child in ipairs(node.children) do
        if child.tag == tag then return child end
    end
    return nil
end

local function collectAll(node, tag, result)
    for _, child in ipairs(node.children) do
        if child.tag == tag then
            result[#result + 1] = child
        end
        collectAll(child, tag, result)
    end
end

local function findAll(node, tag)
    local result = {}
    collectAll(node, tag, result)
    return result
end

local function trackTypeFromSystem(system)
    local trackSystemNumber = tonumber(system.attrs.TrackSystemNumber or system.attrs.GleissystemID)
    local typeName = tostring(system.attrs.type or "")
    if typeName:find("Steuer", 1, true) or typeName:find("GBS", 1, true) then return "control" end
    if trackSystemNumber == 1 then return "rail" end
    if trackSystemNumber == 2 then return "tram" end
    if trackSystemNumber == 3 then return "road" end
    if trackSystemNumber == 4 then return "auxiliary" end
    return "control"
end

local function trackTypeFromSystemId(trackSystemId, trackTypesBySystemId)
    return trackTypesBySystemId[tostring(trackSystemId)] or "control"
end

local function valueAsNumber(value)
    return value and tonumber(value) or nil
end

local function currentEepLanguage()
    local language = type(EEPLng) == "string" and string.upper(EEPLng) or ""
    if language == "ENG" or language == "GER" or language == "POL" or language == "FRA" then return language end
    return "GER"
end

local function structureIdFromImmobileAttrs(attrs)
    if attrs.ImmoIdx then return "#" .. tostring(attrs.ImmoIdx) end
    return attrs.name or attrs.Name
end

local function modelNameFromGsbname(gsbname, modelNameCache)
    if type(gsbname) ~= "string" or gsbname == "" then return nil end

    if modelNameCache[gsbname] == nil then
        local info = StructureResourceParser.infoForGsbname(gsbname)
        modelNameCache[gsbname] =
            StructureResourceParser.modelNameForLanguage(info, currentEepLanguage()) or false
    end

    return modelNameCache[gsbname] or nil
end

local function structureInfoFromImmobileAttrs(attrs, modelNameCache)
    local id = structureIdFromImmobileAttrs(attrs)
    if not id then return nil end

    local modelName = modelNameFromGsbname(attrs.gsbname, modelNameCache)
    if modelName and modelName ~= "" then
        return {
            id = id,
            name = id .. "_" .. modelName
        }
    end

    return {
        id = id,
        name = attrs.name or attrs.Name or id
    }
end

local function boolFromAttr(val)
    if val == nil then return nil end
    return val ~= "0"
end

local function posAndRotFromDreibein(immobile)
    for _, child in ipairs(immobile.children) do
        if child.tag == "Dreibein" then
            local v = child.children
            if #v < 4 then return end
            local px = tonumber(v[1].attrs.x)
            if not px then return end
            local py, pz = tonumber(v[1].attrs.y) or 0, tonumber(v[1].attrs.z) or 0
            -- Columns of the rotation matrix
            local v1x = tonumber(v[2].attrs.x) or 0
            local v1y = tonumber(v[2].attrs.y) or 0
            local v1z = tonumber(v[2].attrs.z) or 0
            local v2z = tonumber(v[3].attrs.z) or 0
            local v3z = tonumber(v[4].attrs.z) or 0
            local ry = math.asin(math.max(-1, math.min(1, -v1z))) * 180 / math.pi
            local rz, rx
            if math.abs(math.cos(ry * math.pi / 180)) > 1e-6 then
                rz = math.atan(v1y, v1x) * 180 / math.pi
                rx = math.atan(v2z, v3z) * 180 / math.pi
            else
                -- Gimbal lock (rot_y = ±90°): encode all rotation into rot_z
                local v2x = tonumber(v[3].attrs.x) or 0
                local v2y = tonumber(v[3].attrs.y) or 0
                rz = math.atan(-v2x, v2y) * 180 / math.pi
                rx = 0
            end
            return px / 100, py / 100, pz / 100, rx, ry, rz
        end
    end
end

local function buildDiscoveryTable(root)
    local dt = {
        coverage = {
            scenario = true,
            routes = false,
            trains = false,
            rollingStocks = false,
            structures = false,
            signals = false,
            switches = false,
            tracks = false,
            contacts = false
        },
        luaPath = nil,
        cameras = { static = {}, dynamic = {} },
        trains = {},
        rollingStocks = {},
        structures = {},
        signals = {},
        switches = {},
        tracks = { auxiliary = {}, control = {}, road = {}, rail = {}, tram = {} },
        routes = {},
        contacts = {}
    }

    local eepLua = findChild(root, "EEPLua")
    if eepLua then dt.luaPath = eepLua.attrs.LUAPath end

    local routeNamesById = {}
    local options = findChild(root, "Options")
    if options then
        dt.coverage.routes = true
        local routeItems = tonumber(options.attrs.RouteItems) or 0
        for index = 0, routeItems - 1 do
            local routeId = tonumber(options.attrs["RouteId_" .. index])
            local routeName = options.attrs["RouteName_" .. index]
            if routeId and routeName then
                routeNamesById[routeId] = routeName
                dt.routes[#dt.routes + 1] = {
                    id = routeId,
                    name = routeName
                }
            end
        end
    end

    local kammerasammlung = findChild(root, "Kammerasammlung")
    if kammerasammlung then
        dt.coverage.scenario = true
        for _, cam in ipairs(kammerasammlung.children) do
            if cam.tag == "Kammera" and cam.attrs.name then
                if cam.attrs.Dynamic == "1" then
                    dt.cameras.dynamic[#dt.cameras.dynamic + 1] = cam.attrs.name
                else
                    dt.cameras.static[#dt.cameras.static + 1] = cam.attrs.name
                end
            end
        end
    end

    local trackTypesBySystemId = {}
    local gleissysteme = findAll(root, "Gleissystem")
    if #gleissysteme > 0 then
        dt.coverage.signals = true
        dt.coverage.switches = true
        dt.coverage.contacts = true
    end
    for _, gleissystem in ipairs(gleissysteme) do
        local trackType = trackTypeFromSystem(gleissystem)
        local systemId = gleissystem.attrs.GleissystemID or gleissystem.attrs.TrackSystemNumber
        if systemId then trackTypesBySystemId[tostring(systemId)] = trackType end
        for _, gleis in ipairs(gleissystem.children) do
            if gleis.tag == "Gleis" then
                local trackId = tonumber(gleis.attrs.GleisID)
                if trackId then
                    dt.coverage.tracks = true
                    dt.tracks[trackType][#dt.tracks[trackType] + 1] = {
                        id = trackId,
                        reserved = false,
                        reservedByTrainName = nil
                    }
                end
                local switchId = tonumber(gleis.attrs.Key_Id)
                if switchId and gleis.attrs.weichenstellung then
                    dt.switches[#dt.switches + 1] = {
                        keyId = switchId,
                        position = tonumber(gleis.attrs.weichenstellung)
                    }
                end
            end
        end
    end

    local fuhrpark = findChild(root, "Fuhrpark")
    if fuhrpark then
        dt.coverage.trains = true
        dt.coverage.rollingStocks = true
        for _, zugverband in ipairs(fuhrpark.children) do
            if zugverband.tag == "Zugverband" and zugverband.attrs.name then
                local train = {
                    name = zugverband.attrs.name,
                    route = routeNamesById[tonumber(zugverband.attrs.Route)] or "",
                    speed = valueAsNumber(zugverband.attrs.Geschwindigkeit) or 0,
                    targetSpeed = valueAsNumber(zugverband.attrs.sollgeschwindigkeit),
                    couplingFront = valueAsNumber(zugverband.attrs.kupplungvorn),
                    couplingRear = valueAsNumber(zugverband.attrs.kupplunghinten),
                    rollingStockCount = 0,
                    trackType = nil,
                    onTracks = {}
                }
                for _, rollmaterial in ipairs(zugverband.children) do
                    if rollmaterial.tag == "Gleisort" then
                        local trackId = tonumber(rollmaterial.attrs.gleisID)
                        if trackId then
                            train.onTracks[tostring(trackId)] = trackId
                            train.trackType = trackTypeFromSystemId(rollmaterial.attrs.gleissystemID,
                                                                    trackTypesBySystemId)
                            train.trackId = trackId
                            train.trackDistance = valueAsNumber(rollmaterial.attrs.parameter)
                            train.trackDirection = valueAsNumber(rollmaterial.attrs.ausrichtung)
                            train.trackSystem = valueAsNumber(rollmaterial.attrs.gleissystemID)
                        end
                    elseif rollmaterial.tag == "Rollmaterial" and rollmaterial.attrs.name then
                        train.rollingStockCount = train.rollingStockCount + 1
                        dt.rollingStocks[#dt.rollingStocks + 1] = {
                            name = rollmaterial.attrs.name,
                            model = rollmaterial.attrs.typ,
                            tag = rollmaterial.attrs.LuaTag,
                            smoke = tonumber(rollmaterial.attrs.Smoke),
                            trainName = train.name,
                            positionInTrain = train.rollingStockCount - 1,
                            trackType = train.trackType,
                            trackId = train.trackId,
                            trackDistance = train.trackDistance,
                            trackDirection = train.trackDirection,
                            trackSystem = train.trackSystem
                        }
                    end
                end
                dt.trains[#dt.trains + 1] = train
            end
        end
    end

    local gebaeudesammlungen = findAll(root, "Gebaeudesammlung")
    if #gebaeudesammlungen > 0 then dt.coverage.structures = true end
    local structureModelNameCache = {}
    for _, gebaeude in ipairs(gebaeudesammlungen) do
        for _, immobilie in ipairs(gebaeude.children) do
            if immobilie.tag == "Immobilie" or immobilie.tag == "Immobile" then
                local structureInfo = structureInfoFromImmobileAttrs(immobilie.attrs, structureModelNameCache)
                if structureInfo then
                    local attrs = immobilie.attrs
                    local pos_x, pos_y, pos_z, rot_x, rot_y, rot_z =
                        posAndRotFromDreibein(immobilie)
                    dt.structures[#dt.structures + 1] = {
                        id = structureInfo.id,
                        name = structureInfo.name,
                        gsbname = attrs.gsbname,
                        tag = attrs.LuaTag,
                        light = boolFromAttr(attrs.Light),
                        smoke = boolFromAttr(attrs.Smoke),
                        fire = boolFromAttr(attrs.Fire),
                        pos_x = pos_x,
                        pos_y = pos_y,
                        pos_z = pos_z,
                        rot_x = rot_x,
                        rot_y = rot_y,
                        rot_z = rot_z
                    }
                end
            end
        end
    end

    for _, meldung in ipairs(findAll(root, "Meldung")) do
        if meldung.attrs.Key_Id then
            dt.signals[#dt.signals + 1] = {
                name = meldung.attrs.name,
                keyId = tonumber(meldung.attrs.Key_Id)
            }
        end
    end

    local contactCounter = 0
    for _, kontakt in ipairs(findAll(root, "Kontakt")) do
        local luaFn = kontakt.attrs.LuaFn
        if luaFn and luaFn ~= "" then
            contactCounter = contactCounter + 1
            dt.contacts[#dt.contacts + 1] = {
                id = contactCounter,
                tipTxt = kontakt.attrs.TipTxt,
                luaFn = luaFn
            }
        end
    end

    return dt
end

Anl3DiscoveryHelper.buildDiscoveryTable = buildDiscoveryTable

function Anl3DiscoveryHelper.getLuaPath(root)
    local eepLua = findChild(root, "EEPLua")
    return eepLua and eepLua.attrs.LUAPath or nil
end

function Anl3DiscoveryHelper.fillDiscoveries(root)
    local dt = buildDiscoveryTable(root)
    ScenarioDiscovery.initFromAnl3(dt)
    RouteDiscovery.initFromAnl3(dt)
    TrainDiscovery.initFromAnl3(dt)
    StructureDiscovery.initFromAnl3(dt)
    SignalDiscovery.initFromAnl3(dt)
    SwitchDiscovery.initFromAnl3(dt)
    ContactDiscovery.initFromAnl3(dt)
    return dt.coverage, dt
end

return Anl3DiscoveryHelper
