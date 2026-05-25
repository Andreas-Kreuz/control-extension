insulate("ce.hub.data.rollingstock.RollingStockModelInfoRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
    end)

    it("caches parsed info by xml model", function ()
        local Parser = require("ce.hub.eep.resources.RollingStockResourceParser")
        local calls = 0
        local infoForXmlModelStub = stub(Parser, "infoForXmlModel", function ()
            calls = calls + 1
            return {
                axisNamesKnown = true,
                axisNames = { [2] = "Fahrer" },
                textureNames = { [1] = "Fahrziel" }
            }
        end)
        finally(function () infoForXmlModelStub:revert() end)

        local Registry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        local first = Registry.get("Model.3dm")
        local second = Registry.get("Model.3dm")

        assert.equals(1, calls)
        assert.equals(first, second)
        assert.is_true(first:getAxisNamesKnown())
        assert.equals("Fahrer", first.axisNames[2])
        assert.equals("Fahrziel", first.textureNames[1])
    end)

    it("defers parsing and processes queued xml models in batches", function ()
        local Parser = require("ce.hub.eep.resources.RollingStockResourceParser")
        local parsed = {}
        local infoForXmlModelStub = stub(Parser, "infoForXmlModel", function (xmlModel)
            parsed[#parsed + 1] = xmlModel
            return {
                axisNamesKnown = true,
                axisNames = { [1] = "Achse " .. tostring(xmlModel) }
            }
        end)
        finally(function () infoForXmlModelStub:revert() end)

        local Registry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        local first = Registry.peek("ModelA.3dm")
        local duplicate = Registry.peek("ModelA.3dm")
        local second = Registry.peek("ModelB.3dm")

        assert.equals(first, duplicate)
        assert.is_false(first:getAxisNamesKnown())
        assert.is_false(second:getAxisNamesKnown())
        assert.same({}, parsed)

        local parsedFirstBatch = Registry.processPending(1)
        assert.same({ "ModelA.3dm" }, parsedFirstBatch)
        assert.same({ "ModelA.3dm" }, parsed)

        local parsedSecondBatch = Registry.processPending(20)
        assert.same({ "ModelB.3dm" }, parsedSecondBatch)
        assert.same({ "ModelA.3dm", "ModelB.3dm" }, parsed)
    end)

    it("immediate lookup parses a queued xml model only once", function ()
        local Parser = require("ce.hub.eep.resources.RollingStockResourceParser")
        local calls = 0
        local infoForXmlModelStub = stub(Parser, "infoForXmlModel", function ()
            calls = calls + 1
            return {
                axisNamesKnown = true,
                axisNames = { [1] = "Fahrer" }
            }
        end)
        finally(function () infoForXmlModelStub:revert() end)

        local Registry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        Registry.peek("Model.3dm")
        local parsed = Registry.get("Model.3dm")
        local batch = Registry.processPending(20)

        assert.equals(1, calls)
        assert.is_true(parsed:getAxisNamesKnown())
        assert.same({}, batch)
    end)

    it("does not parse missing model info twice after immediate lookup", function ()
        local Parser = require("ce.hub.eep.resources.RollingStockResourceParser")
        local calls = 0
        local infoForXmlModelStub = stub(Parser, "infoForXmlModel", function ()
            calls = calls + 1
            return {}
        end)
        finally(function () infoForXmlModelStub:revert() end)

        local Registry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        local first = Registry.get("Missing.3dm")
        local second = Registry.get("Missing.3dm")

        assert.equals(1, calls)
        assert.equals(first, second)
        assert.is_false(second:getAxisNamesKnown())
    end)
end)
