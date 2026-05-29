insulate("ce.databridge.ServerEventPipeTransport", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end
    local originalIoOpen = io.open

    before_each(function ()
        clearModule("ce.databridge.ServerExchangeFileIo")
        clearModule("ce.databridge.ServerTransportDescriptorReader")
        clearModule("ce.databridge.ServerEventPipeTransport")
    end)

    it("is not ready when the server ready file is missing", function ()
        local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
        local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")
        local serverRunningStub = stub(ServerExchangeFileIo, "isServerRunning", function () return false end)
        local descriptorStub = stub(ServerTransportDescriptorReader, "read", function ()
            error("descriptor should not be read")
        end)
        finally(function () serverRunningStub:revert() end)
        finally(function () descriptorStub:revert() end)

        local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")

        assert.is_false(ServerEventPipeTransport.isReady())
    end)

    it("writes a payload to the descriptor pipe", function ()
        local written = ""
        local closed = false
        local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
        local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")
        local serverRunningStub = stub(ServerExchangeFileIo, "isServerRunning", function () return true end)
        local descriptorStub = stub(ServerTransportDescriptorReader, "read", function ()
            return { eventTransport = "pipe", pipeName = "\\\\.\\pipe\\spec", sessionId = "session" }
        end)
        local ioOpenStub = stub(io, "open", function (name, mode)
            if name ~= "\\\\.\\pipe\\spec" then return originalIoOpen(name, mode) end
            return {
                write = function (_, content) written = written .. content end,
                flush = function () end,
                close = function () closed = true end
            }
        end)
        finally(function () serverRunningStub:revert() end)
        finally(function () descriptorStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")

        assert.is_true(ServerEventPipeTransport.isReady())
        assert.is_true(ServerEventPipeTransport.writeOutgoingEvents("{\"kind\":\"event\"}"))
        assert.equals("{\"kind\":\"event\"}\n", written)
        assert.is_true(closed)
    end)

    it("is not ready when the descriptor pipe cannot be opened", function ()
        local printedMessages = {}
        local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
        local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")
        local serverRunningStub = stub(ServerExchangeFileIo, "isServerRunning", function () return true end)
        local descriptorStub = stub(ServerTransportDescriptorReader, "read", function ()
            return { eventTransport = "pipe", pipeName = "\\\\.\\pipe\\spec", sessionId = "session" }
        end)
        local printStub = stub(_G, "print", function (message) table.insert(printedMessages, message) end)
        local ioOpenStub = stub(io, "open", function () return nil, "missing pipe" end)
        finally(function () serverRunningStub:revert() end)
        finally(function () descriptorStub:revert() end)
        finally(function () printStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")

        assert.is_false(ServerEventPipeTransport.isReady())
        assert.has_no.errors(function ()
            assert.is_false(ServerEventPipeTransport.writeOutgoingEvents("{\"kind\":\"event\"}"))
        end)
        assert.equals(
            "[ServerEventPipeTransport] HINWEIS: Wenn du die Control Extension App nutzen möchtest, " ..
            "starte LUA/ce/control-extension-server.exe im EEP-Verzeichnis.",
            printedMessages[1]
        )
    end)

    it("returns false without throwing when pipe write fails", function ()
        local printedMessages = {}
        local openCalls = 0
        local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
        local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")
        local serverRunningStub = stub(ServerExchangeFileIo, "isServerRunning", function () return true end)
        local descriptorStub = stub(ServerTransportDescriptorReader, "read", function ()
            return { eventTransport = "pipe", pipeName = "\\\\.\\pipe\\spec", sessionId = "session" }
        end)
        local printStub = stub(_G, "print", function (message) table.insert(printedMessages, message) end)
        local ioOpenStub = stub(io, "open", function (name, mode)
            if name ~= "\\\\.\\pipe\\spec" then return originalIoOpen(name, mode) end

            openCalls = openCalls + 1
            if openCalls == 1 then
                return {
                    close = function () end
                }
            end

            return {
                write = function () error("broken pipe") end,
                flush = function () end,
                close = function () end
            }
        end)
        finally(function () serverRunningStub:revert() end)
        finally(function () descriptorStub:revert() end)
        finally(function () printStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")

        assert.is_true(ServerEventPipeTransport.isReady())
        assert.has_no.errors(function ()
            assert.is_false(ServerEventPipeTransport.writeOutgoingEvents("{\"kind\":\"event\"}"))
        end)
        assert.equals(2, openCalls)
        assert.matches("Die Verbindung zum Web Server wurde unterbrochen", printedMessages[1], 1, true)
    end)
end)
