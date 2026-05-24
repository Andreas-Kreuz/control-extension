if CeDebugLoad then print("[#Start] Loading ce.mods.road.TramSwitch ...") end

local ProtectedExecution = require("ce.hub.util.ProtectedExecution")
local Structure = require("ce.hub.data.structures.Structure")
local Switch = require("ce.hub.data.switches.Switch")
local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")
local TramSwitch = {}
--- Registriert eine neue Strassenbahnweiche und schaltet das Licht der angegeben Immobilien anhand der Weichenstellung
-- @param switchId ID der Weiche
---@param structure1 string Immobilie, deren Licht bei Weichenstellung 1 leuchten soll
---@param structure2 string Immobilie, deren Licht bei Weichenstellung 2 leuchten soll
---@param structure3? string Immobilie, deren Licht bei Weichenstellung 3 leuchten soll
--
function TramSwitch.new(switchId, structure1, structure2, structure3)
    Switch.registerSwitch(switchId)
    _G["EEPOnSwitch_" .. switchId] = function (_)
        ProtectedExecution.run("EEPOnSwitch_" .. switchId, function ()
            local currentPosition = SwitchRegistry.getOrCreate(switchId):pullPosition()
            if structure1 then Structure.setLightByName(structure1, currentPosition == 1) end
            if structure2 then Structure.setLightByName(structure2, currentPosition == 2) end
            if structure3 then Structure.setLightByName(structure3, currentPosition == 3) end
        end)
    end
    _G["EEPOnSwitch_" .. switchId]()
end

return TramSwitch
