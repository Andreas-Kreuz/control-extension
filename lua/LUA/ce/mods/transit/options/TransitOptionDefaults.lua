if CeDebugLoad then print("[#Start] Loading ce.mods.transit.options.TransitOptionDefaults ...") end

local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")

local TransitOptionDefaults = {}

-- NOTE: data collection cannot be disabled per ceType — the entire module is skipped on loading.
-- Only publish and field-level policies (always / oninterest / never) are configurable here.
function TransitOptionDefaults.create()
    return {
        ceTypes = {
            stations = {
                ceType = TransitCeTypes.Station,
                publish = true,
                fieldUpdates = {
                    platforms = "always",
                    queue = "oninterest"
                },
                fieldPublish = {
                    platforms = "always",
                    queue = "oninterest"
                }
            },
            lines = {
                ceType = TransitCeTypes.Line,
                publish = true,
                fieldUpdates = {
                    nr = "always",
                    trafficType = "always",
                    lineSegments = "always"
                },
                fieldPublish = {
                    nr = "always",
                    trafficType = "always",
                    lineSegments = "always"
                }
            },
            lineNames = {
                ceType = TransitCeTypes.LineName,
                publish = true,
                fieldUpdates = {
                    nr = "always",
                    trafficType = "always",
                    lineSegments = "always"
                },
                fieldPublish = {
                    nr = "always",
                    trafficType = "always",
                    lineSegments = "always"
                }
            },
            transitTrains = {
                ceType = TransitCeTypes.TransitTrain,
                publish = true,
                fieldUpdates = {
                    line = "always",
                    destination = "always",
                    direction = "always"
                },
                fieldPublish = {
                    line = "always",
                    destination = "always",
                    direction = "always"
                }
            },
            moduleSettings = {
                ceType = TransitCeTypes.ModuleSetting,
                publish = true,
                fieldUpdates = {
                    category = "always",
                    description = "always",
                    eepFunction = "always",
                    type = "always",
                    value = "always"
                },
                fieldPublish = {
                    category = "always",
                    description = "always",
                    eepFunction = "always",
                    type = "always",
                    value = "always"
                }
            }
        }
    }
end

return TransitOptionDefaults
