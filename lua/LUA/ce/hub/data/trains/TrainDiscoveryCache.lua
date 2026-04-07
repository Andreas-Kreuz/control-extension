if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDiscoveryCache ...") end

local TrainDiscoveryCache = {}

local entriesByTrainName = {}

function TrainDiscoveryCache.replaceAll(entries)
    entriesByTrainName = entries or {}
end

function TrainDiscoveryCache.get(trainName)
    return entriesByTrainName[trainName]
end

function TrainDiscoveryCache.getAll()
    local copy = {}
    for trainName, entry in pairs(entriesByTrainName) do copy[trainName] = entry end
    return copy
end

function TrainDiscoveryCache.clear()
    entriesByTrainName = {}
end

return TrainDiscoveryCache
