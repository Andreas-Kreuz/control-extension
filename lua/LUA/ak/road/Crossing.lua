-- THIS IS A COMPAT FILE FOR THE OLD API.
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local settingsFields = { showRequestsOnSignal = true, showSequenceOnSignal = true, showSignalIdOnSignal = true }
local Crossing = setmetatable({
                                  allCrossings = Intersection.allIntersections,
                                  loadSettingsFromSlot = IntersectionSettings.loadSettingsFromSlot,
                                  saveSettings = IntersectionSettings.saveSettings,
                                  setShowRequestsOnSignal = IntersectionSettings.setShowRequestsOnSignal,
                                  setShowSequenceOnSignal = IntersectionSettings.setShowSequenceOnSignal,
                                  setShowSignalIdOnSignal = IntersectionSettings.setShowSignalIdOnSignal,
                              }, {
                                  __index = function (t, k)
                                      return settingsFields[k] and IntersectionSettings[k] or Intersection[k]
                                  end,
                                  __newindex = function (t, k, v)
                                      if settingsFields[k] then IntersectionSettings[k] = v else rawset(t, k, v) end
                                  end,
                              })
return Crossing
