-- THIS IS A COMPAT FILE FOR THE OLD API.
local Line = require("ce.mods.transit.Line")
local TransitSettings = require("ce.mods.transit.TransitSettings")
local settingsFields = { showDepartureTippText = true }
local AkLine = setmetatable({
                                loadSettingsFromSlot = TransitSettings.loadSettingsFromSlot,
                                saveSettings = TransitSettings.saveSettings,
                                setShowDepartureTippText = TransitSettings.setShowDepartureTippText,
                            }, {
                                __index = function (_, k)
                                    return settingsFields[k] and TransitSettings[k] or Line[k]
                                end,
                                __newindex = function (t, k, v)
                                    if settingsFields[k] then TransitSettings[k] = v else rawset(t, k, v) end
                                end,
                            })
return AkLine
