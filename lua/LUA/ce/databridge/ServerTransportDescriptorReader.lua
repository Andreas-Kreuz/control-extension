if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerTransportDescriptorReader ...") end

local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
local json = require("ce.third-party.json")

local ServerTransportDescriptorReader = {}

local function descriptorFileName()
    return ExchangeDirRegistry.getExchangeDirectory() .. "/server-transport.json"
end

local function readFile(fileName)
    local file = io.open(fileName, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

function ServerTransportDescriptorReader.read()
    local okRead, content = pcall(readFile, descriptorFileName())
    if not okRead or not content or content == "" then return nil end

    local okDecode, descriptor = pcall(json.decode, content)
    if not okDecode or type(descriptor) ~= "table" then return nil end
    if descriptor.eventTransport ~= "pipe" then return nil end
    if type(descriptor.pipeName) ~= "string" or descriptor.pipeName == "" then return nil end
    if type(descriptor.sessionId) ~= "string" or descriptor.sessionId == "" then return nil end

    return descriptor
end

return ServerTransportDescriptorReader
