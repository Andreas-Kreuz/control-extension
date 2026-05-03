local EepCompatibilityApi = {}

-- EEP 18.1
EEPSwitchGetTagText = EEPSwitchGetTagText or function () end

-- EEP 18.1
if not _G.EEPRollingstockSetAxisByNumber then
    rawset(_G, "EEPRollingstockSetAxisByNumber", function (rollingStockName, axisNumber, axisValue)
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        return RollingStockRegistry.forName(rollingStockName):setAxisByNameFallback(axisNumber, axisValue)
    end)
end

-- EEP 16.3
EEPRollingstockGetTextureText = EEPRollingstockGetTextureText or function () end

-- EEP 17.0
EEPLng = type(EEPLng) == "string" and EEPLng or "GER"
if EEPLng == "" then EEPLng = "GER" end

-- EEP 16.1
EEPRollingstockGetMileage = EEPRollingstockGetMileage or function () end

-- EEP 16.1
EEPRollingstockGetPosition = EEPRollingstockGetPosition or function () end

-- EEP 15.0
EEPRollingstockGetLength = EEPRollingstockGetLength or function () end

-- EEP 15.0
EEPRollingstockGetMotor = EEPRollingstockGetMotor or function () end

-- EEP 15.0
EEPRollingstockGetTrack = EEPRollingstockGetTrack or function () end

-- EEP 15.0
EEPRollingstockGetModelType = EEPRollingstockGetModelType or function () end

-- EEP 15.0
EEPRollingstockGetTagText = EEPRollingstockGetTagText or function () end

-- EEP 13.2
EepCompatibilityApi.EEPGetTrainLength = EEPGetTrainLength or function (trainName)
    ---@type fun(trainName: string):number
    local getRollingStockItemsCount = EEPGetRollingstockItemsCount
    ---@type fun(trainName: string, position: number):string
    local getRollingStockItemName = EEPGetRollingstockItemName
    ---@type fun(rollingStockName: string):boolean, number
    local getRollingStockLength = EEPRollingstockGetLength
    local rollingStockCount = getRollingStockItemsCount(trainName)
    local ok = rollingStockCount > 0
    local length = 0
    if ok then
        for i = 0, (rollingStockCount - 1) do
            local rollingStockName = getRollingStockItemName(trainName, i)
            local _, rslength = getRollingStockLength(rollingStockName)
            length = length + rslength
        end
    end
    return ok, length
end

return EepCompatibilityApi
