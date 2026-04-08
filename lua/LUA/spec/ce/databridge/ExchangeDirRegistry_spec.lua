insulate("ce.databridge.ExchangeDirRegistry", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end

    local originalIoOpen = io.open
    local originalCeTestingMode = CeTestingMode

    before_each(function ()
        clearModule("ce.databridge.ExchangeDirRegistry")
        io.open = originalIoOpen
        CeTestingMode = originalCeTestingMode
    end)

    after_each(function ()
        io.open = originalIoOpen
        CeTestingMode = originalCeTestingMode
    end)

    it("stores the resolved default exchange directory during module load", function ()
        local openCalls = {}

        io.open = function (name, mode)
            if name ~= "./ce/databridge/exchange-test/ce-version.txt" then
                return originalIoOpen(name, mode)
            end

            table.insert(openCalls, { name = name, mode = mode })
            return { write = function () end, flush = function () end, close = function () end }
        end

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")

        assert.equals("./ce/databridge/exchange-test", ExchangeDirRegistry.getExchangeDirectory())
        assert.equals("./ce/databridge/exchange-test", ExchangeDirRegistry.resolveDefaultExchangeDirectory())
        assert.same({
                        { name = "./ce/databridge/exchange-test/ce-version.txt", mode = "w" },
                        { name = "./ce/databridge/exchange-test/ce-version.txt", mode = "w" }
                    }, openCalls)
    end)

    it("keeps the production default resolution when test mode is disabled", function ()
        local openCalls = {}
        rawset(_G, "CeTestingMode", false)
        clearModule("ce.databridge.ExchangeDirRegistry")

        io.open = function (name, mode)
            if name ~= "../LUA/ce/databridge/exchange/ce-version.txt" and
                name ~= "./LUA/ce/databridge/exchange/ce-version.txt" then
                return originalIoOpen(name, mode)
            end

            table.insert(openCalls, { name = name, mode = mode })
            if name == "../LUA/ce/databridge/exchange/ce-version.txt" then return nil end
            return { write = function () end, flush = function () end, close = function () end }
        end

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")

        assert.equals("./LUA/ce/databridge/exchange", ExchangeDirRegistry.getExchangeDirectory())
        rawset(_G, "CeTestingMode", false)
        assert.equals("./LUA/ce/databridge/exchange", ExchangeDirRegistry.resolveDefaultExchangeDirectory())
        assert.same({
                        { name = "../LUA/ce/databridge/exchange/ce-version.txt", mode = "w" },
                        { name = "./LUA/ce/databridge/exchange/ce-version.txt",  mode = "w" },
                        { name = "../LUA/ce/databridge/exchange/ce-version.txt", mode = "w" },
                        { name = "./LUA/ce/databridge/exchange/ce-version.txt",  mode = "w" }
                    }, openCalls)
    end)

    it("stores a validated exchange directory", function ()
        local openCalls = {}

        io.open = function (name, mode)
            if name ~= "./ce/databridge/exchange-test/ce-version.txt" and
                name ~= "exchange-dir/ce-version.txt" then
                return originalIoOpen(name, mode)
            end

            table.insert(openCalls, { name = name, mode = mode })
            return { write = function () end, flush = function () end, close = function () end }
        end

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")

        openCalls = {}
        assert.equals("exchange-dir", ExchangeDirRegistry.setExchangeDirectory("exchange-dir"))
        assert.equals("exchange-dir", ExchangeDirRegistry.getExchangeDirectory())
        assert.same({ { name = "exchange-dir/ce-version.txt", mode = "w" } }, openCalls)
    end)
end)
