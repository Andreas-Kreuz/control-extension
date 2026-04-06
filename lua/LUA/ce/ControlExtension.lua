if AkDebugLoad then print("[#Start] Loading ce.ControlExtension ...") end

local ControlExtensionHub = require("ce.hub.ControlExtensionHub")
local ModuleRegistry = require("ce.hub.ModuleRegistry")

local ControlExtension = {}

function ControlExtension.addModules(...)
    ModuleRegistry.registerModules(...)
    return ControlExtension
end

function ControlExtension.initTasks()
    ControlExtensionHub.initTasks()
    return ControlExtension
end

function ControlExtension.runTasks(cycleCount)
    return ControlExtensionHub.runTasks(cycleCount)
end

function ControlExtension.activateServer()
    ControlExtensionHub.activateServer()
    return ControlExtension
end

function ControlExtension.deactivateServer()
    ControlExtensionHub.deactivateServer()
    return ControlExtension
end

function ControlExtension.setDebug(debug)
    ControlExtensionHub.setDebug(debug)
    return ControlExtension
end

function ControlExtension.setPauseEepDuringInitialization(pauseEepDuringInitialization)
    ControlExtensionHub.setPauseEepDuringInitialization(pauseEepDuringInitialization)
    return ControlExtension
end

function ControlExtension.setOptions(options)
    ControlExtensionHub.setOptions(options)
    return ControlExtension
end

return ControlExtension
