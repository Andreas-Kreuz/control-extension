if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerEventPipeTransport ...") end

local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")

local ServerEventPipeTransport = {}
ServerEventPipeTransport.name = "pipe"
ServerEventPipeTransport.debug = CeStartWithDebug or false

local descriptor
local lastErrorMessage

local function logFailure(message)
    if lastErrorMessage == message then return end
    lastErrorMessage = message
    print("[#ServerEventPipeTransport] " .. message)
end

local function safeClose(file)
    if file then pcall(function () file:close() end) end
end

local function refreshDescriptor()
    descriptor = ServerTransportDescriptorReader.read()
    return descriptor
end

function ServerEventPipeTransport.isReady()
    if not ServerExchangeFileIo.isServerRunning() then
        descriptor = nil
        return false
    end

    return refreshDescriptor() ~= nil
end

function ServerEventPipeTransport.getSessionId()
    if not descriptor then refreshDescriptor() end
    return descriptor and descriptor.sessionId or nil
end

function ServerEventPipeTransport.writeOutgoingEvents(jsonData)
    if jsonData == "" then return true end
    if not descriptor and not ServerEventPipeTransport.isReady() then return false end

    local opened, fileOrError = pcall(io.open, descriptor.pipeName, "w")
    if not opened or not fileOrError then
        logFailure("Cannot open pipe: " .. tostring(fileOrError))
        return false
    end

    local file = fileOrError
    local okWrite, writeError = pcall(function ()
        file:write(jsonData .. "\n")
        file:flush()
    end)

    if not okWrite then
        safeClose(file)
        logFailure("Cannot write pipe: " .. tostring(writeError))
        return false
    end

    local okClose, closeError = pcall(function () file:close() end)
    if not okClose then
        logFailure("Cannot close pipe: " .. tostring(closeError))
        return false
    end

    lastErrorMessage = nil
    return true
end

return ServerEventPipeTransport
