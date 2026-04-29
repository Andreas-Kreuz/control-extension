insulate("ce.hub.data.rollingstock.RollingStockModelInfoRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
    end)

    it("caches parsed info by xml model", function ()
        local Parser = require("ce.hub.eep.RollingStockResourceParser")
        local originalInfoForXmlModel = Parser.infoForXmlModel
        local calls = 0
        Parser.infoForXmlModel = function ()
            calls = calls + 1
            return {
                axisNames = { [2] = "Fahrer" },
                textureNames = { [1] = "Fahrziel" }
            }
        end

        local Registry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
        local first = Registry.infoForXmlModel("Model.3dm")
        local second = Registry.infoForXmlModel("Model.3dm")

        Parser.infoForXmlModel = originalInfoForXmlModel

        assert.equals(1, calls)
        assert.equals(first, second)
        assert.equals("Fahrer", first.axisNames[2])
        assert.equals("Fahrziel", first.textureNames[1])
    end)
end)
