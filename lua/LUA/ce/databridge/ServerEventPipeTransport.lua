if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerEventPipeTransport ...") end

local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")

local ServerEventPipeTransport = {}
ServerEventPipeTransport.name = "pipe"
ServerEventPipeTransport.debug = CeStartWithDebug or false

local descriptor
local lastErrorMessage

local function serverStartHint()
    return "HINWEIS: Starte LUA/ce/control-extension-server.exe im EEP-Verzeichnis, " ..
        "wenn du den Web Server der Control Extension fuer EEP verwenden willst."
end

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

local function pipeIsAvailable(nextDescriptor)
    local opened, fileOrError = pcall(io.open, nextDescriptor.pipeName, "w")
    if not opened or not fileOrError then
        descriptor = nil
        logFailure(serverStartHint())
        return false
    end

    safeClose(fileOrError)
    return true
end

function ServerEventPipeTransport.isReady()
    if not ServerExchangeFileIo.isServerRunning() then
        descriptor = nil
        return false
    end

    local nextDescriptor = refreshDescriptor()
    return nextDescriptor ~= nil and pipeIsAvailable(nextDescriptor)
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
        descriptor = nil
        logFailure(serverStartHint())
        return false
    end

    local file = fileOrError
    local okWrite, writeError = pcall(function ()
        file:write(jsonData .. "\n")
        file:flush()
    end)

    if not okWrite then
        safeClose(file)
        descriptor = nil
        logFailure("Die Verbindung zum Web Server wurde unterbrochen: " .. tostring(writeError))
        return false
    end

    local okClose, closeError = pcall(function () file:close() end)
    if not okClose then
        descriptor = nil
        logFailure("Die Verbindung zum Web Server wurde unterbrochen: " .. tostring(closeError))
        return false
    end

    lastErrorMessage = nil
    return true
end

return ServerEventPipeTransport
