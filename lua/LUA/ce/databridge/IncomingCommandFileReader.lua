if CeDebugLoad then print("[#Start] Loading ce.databridge.IncomingCommandFileReader ...") end
local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")

local IncomingCommandFileReader = {}

local commandsToCeFileName
local lastConsumedByteOffset = 0
local preparedCommandFileNames = {}

local function writeFile(fileName, content)
    local file = io.open(fileName, "w")
    assert(file, fileName)
    file:write(content)
    file:flush()
    file:close()
end

local function readFile(fileName)
    local file = io.open(fileName, "r")
    assert(file, fileName)
    local content = file:read("*all")
    file:close()
    return content or ""
end

local function prepareCommandFile()
    local nextCommandsToCeFileName = ExchangeDirRegistry.getExchangeDirectory() .. "/commands-to-ce"

    if commandsToCeFileName ~= nextCommandsToCeFileName then
        commandsToCeFileName = nextCommandsToCeFileName
        lastConsumedByteOffset = 0
    end
    if not preparedCommandFileNames[nextCommandsToCeFileName] then
        writeFile(nextCommandsToCeFileName, "")
        preparedCommandFileNames[nextCommandsToCeFileName] = true
    end
    return nextCommandsToCeFileName
end

function IncomingCommandFileReader.readAndExecuteIncomingCommands()
    local commandFileName = prepareCommandFile()
    local commands = readFile(commandFileName) -- file: commands-to-ce
    if commands:len() < lastConsumedByteOffset then lastConsumedByteOffset = 0 end

    local newCommands = commands:sub(lastConsumedByteOffset + 1)
    lastConsumedByteOffset = commands:len()
    if newCommands ~= "" then IncomingCommandExecutor.executeIncomingCommands(newCommands) end
end

return IncomingCommandFileReader
