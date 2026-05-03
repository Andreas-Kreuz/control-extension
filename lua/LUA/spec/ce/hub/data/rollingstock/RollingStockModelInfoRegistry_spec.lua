insulate("ce.hub.data.rollingstock.RollingStockModelInfoRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
    end)

    it("caches parsed info by xml model", function ()
        local Parser = require("ce.hub.eep.RollingStockResourceParser")
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
        local first = Registry.infoForXmlModel("Model.3dm")
        local second = Registry.infoForXmlModel("Model.3dm")

        assert.equals(1, calls)
        assert.equals(first, second)
        assert.is_true(first:getAxisNamesKnown())
        assert.equals("Fahrer", first.axisNames[2])
        assert.equals("Fahrziel", first.textureNames[1])
    end)
end)
