if AkDebugLoad then print("[#Start] Loading ce.databridge.DataStoreFileWriter ...") end
local InternalDataStore = require("ce.hub.publish.InternalDataStore")
local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
local json = require("ce.third-party.json")

local DataStoreFileWriter = {}

function DataStoreFileWriter.write()
    local encodedCeTypes = json.encode(InternalDataStore.ceTypes)
    local fileName = ExchangeDirRegistry.getExchangeDirectory() .. "/ak-eep-lib-store.json"
    local file = io.open(fileName, "w")
    assert(file, fileName)
    file:write(encodedCeTypes)
    file:flush()
    file:close()
    return encodedCeTypes
end

return DataStoreFileWriter
