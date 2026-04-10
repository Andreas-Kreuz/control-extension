if CeDebugLoad then print("[#Start] Loading ce.hub.eep.Anl3DiscoveryHelper ...") end

local ScenarioDiscovery = require("ce.hub.data.scenario.ScenarioDiscovery")
local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
local ContactDiscovery = require("ce.hub.data.contacts.ContactDiscovery")

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

local function buildDiscoveryTable(root)
    local dt = {
        luaPath = nil,
        cameras = { static = {}, dynamic = {} },
        trains = {},
        rollingStocks = {},
        structures = {},
        signals = {},
        contacts = {}
    }

    local eepLua = findChild(root, "EEPLua")
    if eepLua then dt.luaPath = eepLua.attrs.LUAPath end

    local kammerasammlung = findChild(root, "Kammerasammlung")
    if kammerasammlung then
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

    local fuhrpark = findChild(root, "Fuhrpark")
    if fuhrpark then
        for _, zugverband in ipairs(fuhrpark.children) do
            if zugverband.tag == "Zugverband" and zugverband.attrs.name then
                dt.trains[#dt.trains + 1] = { name = zugverband.attrs.name }
                for _, rollmaterial in ipairs(zugverband.children) do
                    if rollmaterial.tag == "Rollmaterial" and rollmaterial.attrs.name then
                        dt.rollingStocks[#dt.rollingStocks + 1] = {
                            name = rollmaterial.attrs.name,
                            model = rollmaterial.attrs.typ
                        }
                    end
                end
            end
        end
    end

    for _, gebaeude in ipairs(findAll(root, "Gebaeudesammlung")) do
        for _, immobilie in ipairs(gebaeude.children) do
            if immobilie.tag == "Immobilie" and immobilie.attrs.name then
                dt.structures[#dt.structures + 1] = {
                    name = immobilie.attrs.name,
                    gsbname = immobilie.attrs.gsbname
                }
            end
        end
    end

    for _, meldung in ipairs(findAll(root, "Meldung")) do
        if meldung.attrs.name then
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

function Anl3DiscoveryHelper.getLuaPath(root)
    local eepLua = findChild(root, "EEPLua")
    return eepLua and eepLua.attrs.LUAPath or nil
end

function Anl3DiscoveryHelper.fillDiscoveries(root)
    local dt = buildDiscoveryTable(root)
    ScenarioDiscovery.initFromAnl3(dt)
    TrainDiscovery.initFromAnl3(dt)
    StructureDiscovery.initFromAnl3(dt)
    SignalDiscovery.initFromAnl3(dt)
    ContactDiscovery.initFromAnl3(dt)
end

return Anl3DiscoveryHelper
