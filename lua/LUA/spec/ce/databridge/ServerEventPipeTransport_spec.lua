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

    it("returns false without throwing when pipe open or write fails", function ()
        local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
        local ServerTransportDescriptorReader = require("ce.databridge.ServerTransportDescriptorReader")
        local serverRunningStub = stub(ServerExchangeFileIo, "isServerRunning", function () return true end)
        local descriptorStub = stub(ServerTransportDescriptorReader, "read", function ()
            return { eventTransport = "pipe", pipeName = "\\\\.\\pipe\\spec", sessionId = "session" }
        end)
        local printStub = stub(_G, "print", function () end)
        local ioOpenStub = stub(io, "open", function () return nil, "missing pipe" end)
        finally(function () serverRunningStub:revert() end)
        finally(function () descriptorStub:revert() end)
        finally(function () printStub:revert() end)
        finally(function () ioOpenStub:revert() end)

        local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")

        assert.is_true(ServerEventPipeTransport.isReady())
        assert.has_no.errors(function ()
            assert.is_false(ServerEventPipeTransport.writeOutgoingEvents("{\"kind\":\"event\"}"))
        end)

        ioOpenStub:revert()
        ioOpenStub = stub(io, "open", function ()
            return {
                write = function () error("broken pipe") end,
                flush = function () end,
                close = function () end
            }
        end)

        assert.has_no.errors(function ()
            assert.is_false(ServerEventPipeTransport.writeOutgoingEvents("{\"kind\":\"event\"}"))
        end)
    end)
end)
