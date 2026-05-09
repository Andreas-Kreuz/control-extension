insulate("ce.databridge.IncomingCommandFileReader", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end

    local originalIoOpen = io.open

    before_each(function ()
        clearModule("ce.databridge.ExchangeDirRegistry")
        clearModule("ce.databridge.IncomingCommandExecutor")
        clearModule("ce.databridge.SafeFileIo")
        clearModule("ce.hub.util.ProtectedExecution")
        clearModule("ce.databridge.IncomingCommandFileReader")
    end)

    local function clearTable(t)
        for key in pairs(t) do t[key] = nil end
    end

    local function stubFileIo(files, openCalls, closeCalls)
        return stub(io, "open", function (name, mode)
            if not string.find(name, "ce%-version%.txt") and not string.find(name, "commands%-to%-ce") then
                return originalIoOpen(name, mode)
            end

            table.insert(openCalls, { name = name, mode = mode })
            if mode == "r" then
                return {
                    read = function ()
                        if files[name] == "__READ_ERROR__" then error("read failed") end
                        return files[name] or ""
                    end,
                    close = function () closeCalls[name] = (closeCalls[name] or 0) + 1 end
                }
            end

            if files[name] == "__WRITE_ERROR__" then error("write failed") end
            files[name] = ""
            return {
                write = function (_, content) files[name] = files[name] .. content end,
                flush = function () end,
                close = function () closeCalls[name] = (closeCalls[name] or 0) + 1 end
            }
        end)
    end

    it("truncates the command file once on startup and closes files within the cycle", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = { ["custom-dir/commands-to-ce"] = "stale|" }

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
        end)
        finally(function () executeIncomingCommandsStub:revert() end)

        clearTable(openCalls)
        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same(
            {
                { name = "custom-dir/ce-version.txt", mode = "w" },
                { name = "custom-dir/commands-to-ce", mode = "w" },
                { name = "custom-dir/commands-to-ce", mode = "r" }
            }, openCalls)
        assert.same({}, commands)
        assert.equals("", files["custom-dir/commands-to-ce"])
        assert.equals(2, closeCalls["custom-dir/commands-to-ce"])
    end)

    it("opens and closes the command file each cycle and executes only appended commands", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = {}

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
        end)
        finally(function () executeIncomingCommandsStub:revert() end)

        clearTable(openCalls)
        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "print|one\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "print|one\nprint|two\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same({ "print|one\n", "print|two\n" }, commands)
        assert.equals(4, closeCalls["custom-dir/commands-to-ce"])
        assert.same(
            {
                { name = "custom-dir/ce-version.txt", mode = "w" },
                { name = "custom-dir/commands-to-ce", mode = "w" },
                { name = "custom-dir/commands-to-ce", mode = "r" },
                { name = "custom-dir/commands-to-ce", mode = "r" },
                { name = "custom-dir/commands-to-ce", mode = "r" }
            }, openCalls)
    end)

    it("executes from the beginning when the command file was externally truncated", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = {}

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
                                                 end)
        finally(function () executeIncomingCommandsStub:revert() end)

        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "print|one\nprint|two\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "clearlog\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same({ "print|one\nprint|two\n", "clearlog\n" }, commands)
    end)

    it("truncates the command file again when the exchange directory changes", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = { ["other-dir/commands-to-ce"] = "stale|" }

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
                                                 end)
        finally(function () executeIncomingCommandsStub:revert() end)

        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        clearTable(openCalls)
        ExchangeDirRegistry.setExchangeDirectory("other-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["other-dir/commands-to-ce"] = "clearlog\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same(
            {
                { name = "other-dir/ce-version.txt", mode = "w" },
                { name = "other-dir/commands-to-ce", mode = "w" },
                { name = "other-dir/commands-to-ce", mode = "r" },
                { name = "other-dir/commands-to-ce", mode = "r" }
            }, openCalls)
        assert.same({ "clearlog\n" }, commands)
        assert.equals("", files["custom-dir/commands-to-ce"])
    end)

    it("does not mark the command file as prepared when startup truncation fails", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = { ["custom-dir/commands-to-ce"] = "__WRITE_ERROR__" }

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        local printStub = stub(_G, "print", function () end)
        finally(function () ioOpenStub:revert() end)
        finally(function () printStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
                                                 end)
        finally(function () executeIncomingCommandsStub:revert() end)

        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "stale|"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same({}, commands)
        assert.equals("", files["custom-dir/commands-to-ce"])
    end)

    it("does not advance the consumed offset when reading fails", function ()
        local openCalls = {}
        local closeCalls = {}
        local commands = {}
        local files = {}

        local ioOpenStub = stubFileIo(files, openCalls, closeCalls)
        local printStub = stub(_G, "print", function () end)
        finally(function () ioOpenStub:revert() end)
        finally(function () printStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IncomingCommandFileReader = require("ce.databridge.IncomingCommandFileReader")
        local executeIncomingCommandsStub = stub(IncomingCommandExecutor, "executeIncomingCommands",
                                                 function (commandText)
                                                     table.insert(commands, commandText)
                                                 end)
        finally(function () executeIncomingCommandsStub:revert() end)

        ExchangeDirRegistry.setExchangeDirectory("custom-dir")
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "print|one\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "__READ_ERROR__"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()
        files["custom-dir/commands-to-ce"] = "print|one\nprint|two\n"
        IncomingCommandFileReader.readAndExecuteIncomingCommands()

        assert.same({ "print|one\n", "print|two\n" }, commands)
    end)
end)
