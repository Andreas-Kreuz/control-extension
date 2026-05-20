---@diagnostic disable: param-type-mismatch
insulate("ce.databridge.LogOutputFileWriter", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end

    local originalIoOpen = io.open
    local originalAssert = assert
    local originalError = error
    local originalPrint = print
    local originalWarn = warn
    local originalClearlog = clearlog
    local originalOsDate = os.date

    local function installSimpleGlobals()
        local assertStub = stub(_G, "assert", function (v, message)
            if not v then originalError(message and message or "Assertion failed.", 0) end
            return v
        end)
        local errorStub = stub(_G, "error", function (message, level) originalError(message, level and level or 1) end)
        local printStub = stub(_G, "print", function () end)
        local warnStub = stub(_G, "warn", function () end)
        local clearlogStub = stub(_G, "clearlog", function () end)

        return { assertStub, errorStub, printStub, warnStub, clearlogStub }
    end

    local function revertStubs(stubs)
        for i = #stubs, 1, -1 do stubs[i]:revert() end
    end

    before_each(function ()
        clearModule("ce.databridge.ExchangeDirRegistry")
        clearModule("ce.databridge.IncomingCommandExecutor")
        clearModule("ce.databridge.LogOutputFileWriter")
        rawset(io, "open", originalIoOpen)
        rawset(_G, "assert", originalAssert)
        rawset(_G, "error", originalError)
        rawset(_G, "print", originalPrint)
        rawset(_G, "warn", originalWarn)
        rawset(_G, "clearlog", originalClearlog)
        rawset(os, "date", originalOsDate)
    end)

    after_each(function ()
        rawset(io, "open", originalIoOpen)
        rawset(_G, "assert", originalAssert)
        rawset(_G, "error", originalError)
        rawset(_G, "print", originalPrint)
        rawset(_G, "warn", originalWarn)
        rawset(_G, "clearlog", originalClearlog)
        rawset(os, "date", originalOsDate)
    end)

    it("writes newline-terminated log entries and reset markers", function ()
        local logWrites = {}
        local logOpenModes = {}

        local simpleGlobalStubs = installSimpleGlobals()
        local osDateStub = stub(os, "date", function () return "" end)
        local ioOpenStub = stub(io, "open", function (name, mode)
            if name ~= "./ce/databridge/exchange-test/ce-version.txt" and
                name ~= "exchange-dir/ce-version.txt" and
                name ~= "exchange-dir/log-from-ce" then
                return originalIoOpen(name, mode)
            end

            if name == "exchange-dir/log-from-ce" then
                table.insert(logOpenModes, mode)
            end

            return {
                write = function (_, content)
                    if name == "exchange-dir/log-from-ce" then table.insert(logWrites, content) end
                end,
                flush = function () end,
                close = function () end
            }
        end)
        finally(function () revertStubs(simpleGlobalStubs) end)
        finally(function () osDateStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local LogOutputFileWriter = require("ce.databridge.LogOutputFileWriter")

        ExchangeDirRegistry.setExchangeDirectory("exchange-dir")
        LogOutputFileWriter.initialize()

        _G.print("Line 1\nLine 2")
        _G.clearlog()

        originalAssert.same({ "w+", "a", "a" }, logOpenModes)
        originalAssert.same({ "Line 1\n       . Line 2\n", "@@CE_LOG_RESET@@\n" }, logWrites)
        for _, content in ipairs(logWrites) do
            originalAssert.equals("\n", content:sub(-1))
        end
    end)

    it("registers wrapped print and keeps assert fail-loud", function ()
        local openCalls = {}

        local simpleGlobalStubs = installSimpleGlobals()
        local ioOpenStub = stub(io, "open", function (name, mode)
            if name ~= "./ce/databridge/exchange-test/ce-version.txt" and
                name ~= "exchange-dir/ce-version.txt" and
                name ~= "exchange-dir/log-from-ce" then
                return originalIoOpen(name, mode)
            end

            table.insert(openCalls, { name = name, mode = mode })
            return { write = function () end, flush = function () end, close = function () end }
        end)
        finally(function () revertStubs(simpleGlobalStubs) end)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local LogOutputFileWriter = require("ce.databridge.LogOutputFileWriter")

        openCalls = {}
        ExchangeDirRegistry.setExchangeDirectory("exchange-dir")
        LogOutputFileWriter.initialize()
        openCalls = {}

        IncomingCommandExecutor.executeIncomingCommands("print|")
        local ok, err = pcall(_G.assert, false, "boom")

        originalAssert.is_true(#openCalls >= 2)
        for _, openCall in ipairs(openCalls) do
            originalAssert.same({ name = "exchange-dir/log-from-ce", mode = "a" }, openCall)
        end
        originalAssert.is_false(ok)
        originalAssert.is_not_nil(string.find(err, "boom", 1, true))
        originalAssert.is_not_nil(string.find(err, "stack traceback", 1, true))
    end)

    it("logs errors with Lua source context outside the log writer wrapper", function ()
        local logWrites = {}

        local simpleGlobalStubs = installSimpleGlobals()
        local osDateStub = stub(os, "date", function () return "" end)
        local ioOpenStub = stub(io, "open", function (name, mode)
            if name ~= "./ce/databridge/exchange-test/ce-version.txt" and
                name ~= "exchange-dir/ce-version.txt" and
                name ~= "exchange-dir/log-from-ce" then
                return originalIoOpen(name, mode)
            end

            return {
                write = function (_, content)
                    if name == "exchange-dir/log-from-ce" and mode == "a" then table.insert(logWrites, content) end
                end,
                flush = function () end,
                close = function () end
            }
        end)
        finally(function () revertStubs(simpleGlobalStubs) end)
        finally(function () osDateStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local LogOutputFileWriter = require("ce.databridge.LogOutputFileWriter")

        ExchangeDirRegistry.setExchangeDirectory("exchange-dir")
        LogOutputFileWriter.initialize()

        local function fail() _G.error("boom") end
        local ok, err = pcall(fail)

        originalAssert.is_false(ok)
        originalAssert.is_not_nil(string.find(logWrites[1], "boom", 1, true))
        originalAssert.is_nil(string.find(logWrites[1], "LogOutputFileWriter.lua", 1, true))
        originalAssert.is_nil(string.find(err, "LogOutputFileWriter.lua", 1, true))
    end)
end)
