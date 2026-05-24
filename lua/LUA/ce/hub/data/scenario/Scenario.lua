if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.Scenario ...") end

---@class Scenario
---@field id string
---@field name string
---@field scenarioName string|nil
---@field scenarioPath string|nil
---@field savedWithEep number|nil
---@field scenarioLanguage string|nil
---@field eepLanguage string|nil
---@field activeTrain string|nil
---@field activeRollingStock string|nil
---@field timeLapse number|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Scenario = {}

local function markDirty(scenario, fieldName)
    scenario.dirtyFields[fieldName] = true
end

local function updateField(scenario, fieldName, value)
    local oldValue = scenario[fieldName]
    scenario[fieldName] = value
    if oldValue ~= value then markDirty(scenario, fieldName) end
end

local function callOptional(fn, ...)
    if type(fn) ~= "function" then return "-" end

    local ok, value = pcall(fn, ...)
    if not ok then return nil end

    return value
end

local function copyList(values)
    local copy = {}
    for _, value in ipairs(values or {}) do copy[#copy + 1] = value end
    return copy
end

local function readActiveTrain()
    return callOptional(EEPGetTrainActive)
end

local function readActiveRollingStock()
    return callOptional(EEPRollingstockGetActive)
end

local function toNumber(value)
    return tonumber(value)
end

function Scenario:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function Scenario.pullCurrent()
    local ScenarioDiscovery = require("ce.hub.data.scenario.ScenarioDiscovery")
    return {
        id = "scenario",
        name = "scenario",
        scenarioName = callOptional(EEPGetAnlName),
        scenarioPath = callOptional(EEPGetAnlPath),
        savedWithEep = callOptional(EEPGetAnlVer),
        scenarioLanguage = callOptional(EEPGetAnlLng),
        eepLanguage = EEPLng,
        activeTrain = readActiveTrain(),
        activeRollingStock = readActiveRollingStock(),
        timeLapse = callOptional(EEPGetTimeLapse),
        staticCameras = copyList(ScenarioDiscovery.getStaticCameras()),
        dynamicCameras = copyList(ScenarioDiscovery.getDynamicCameras())
    }
end

function Scenario:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "scenarioName", values.scenarioName)
    updateField(self, "scenarioPath", values.scenarioPath)
    updateField(self, "savedWithEep", values.savedWithEep)
    updateField(self, "scenarioLanguage", values.scenarioLanguage)
    updateField(self, "eepLanguage", values.eepLanguage)
    updateField(self, "activeTrain", values.activeTrain)
    updateField(self, "activeRollingStock", values.activeRollingStock)
    updateField(self, "timeLapse", values.timeLapse)
end

function Scenario:peekActiveTrain()
    return self.activeTrain
end

function Scenario:setActiveTrain(activeTrain)
    updateField(self, "activeTrain", activeTrain)
end

function Scenario:pullActiveTrain()
    updateField(self, "activeTrain", readActiveTrain())
    return self.activeTrain
end

function Scenario:peekActiveRollingStock()
    return self.activeRollingStock
end

function Scenario:setActiveRollingStock(activeRollingStock)
    updateField(self, "activeRollingStock", activeRollingStock)
end

function Scenario:pullActiveRollingStock()
    updateField(self, "activeRollingStock", readActiveRollingStock())
    return self.activeRollingStock
end

function Scenario.setCamera(cameraType, cameraName)
    local typeNumber = toNumber(cameraType)
    if not typeNumber or not cameraName then return false end
    if not EEPSetCamera then return false end
    return EEPSetCamera(typeNumber, cameraName) ~= false
end

function Scenario.setPerspectiveCamera(cameraPosition, trainName)
    local position = toNumber(cameraPosition)
    if not position then return false end
    if not EEPSetPerspectiveCamera then return false end
    return EEPSetPerspectiveCamera(position, trainName) ~= false
end

function Scenario.setCameraPosition(posX, posY, posZ)
    local x = toNumber(posX)
    local y = toNumber(posY)
    local z = toNumber(posZ)
    if not x or not y or not z then return false end
    if not EEPSetCameraPosition then return false end
    return EEPSetCameraPosition(x, y, z) ~= false
end

function Scenario.setCameraRotation(rotX, rotY, rotZ)
    local x = toNumber(rotX)
    local y = toNumber(rotY)
    local z = toNumber(rotZ)
    if not x or not y or not z then return false end
    if not EEPSetCameraRotation then return false end
    return EEPSetCameraRotation(x, y, z) ~= false
end

function Scenario:resetDirty()
    self.dirtyFields = {}
end

function Scenario:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Scenario
