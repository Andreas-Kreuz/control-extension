describe("ce.hub.data.rollingstock.RollingStock", function ()
    require("ce.hub.eep.EepSimulator")

    insulate("parse rollingstockname", function ()
        local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
        assert(RollingStock)
    end)
end)

insulate("parse rollingstockname", function ()
    local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
    local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")
    local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")

    RollingStockModels.addModel("MyModel", "MODEL_A.3dm", RollingStockModel:new({ myMarker = "MODEL A" }))
    RollingStockModels.assignModel("MyModel;005", RollingStockModel:new({ myMarker = "MODEL B" }))

    local stock1 = RollingStockRegistry.forName("MyModel;003")
    local stock2 = RollingStockRegistry.forName("MyModel;005")

    it("stock1 name", function () assert.equals("MyModel;003", stock1.rollingStockName) end)
    it("stock2 name", function () assert.equals("MyModel;005", stock2.rollingStockName) end)

    it("MODEL A", function () assert.equals("MODEL A", stock1.model["myMarker"]) end)
    it("MODEL B", function () assert.equals("MODEL B", stock2.model["myMarker"]) end)
end)

insulate("axis and texture metadata", function ()
    require("ce.hub.eep.EepSimulator")

    it("includes axis names, texture names and axis values in dto", function ()
        local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
        local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
        local RollingStockModelInfo = require("ce.hub.data.rollingstock.RollingStockModelInfo")

        EEPRollingstockSetAxisByNumber("AxisStock", 2, 75)
        local stock = RollingStock:new({ rollingStockName = "AxisStock" })
        stock.modelInfo = RollingStockModelInfo:new({
            axisNames = { [2] = "Fahrer" },
            textureNames = { [1] = "Fahrziel" }
        })
        stock:updateAxisValues()

        local _, _, _, dto = RollingStockDtoFactory.createFullDto(stock, true)

        assert.equals("Fahrer", dto.axisNames["2"])
        assert.equals(75, dto.axisValues["2"])
        assert.equals("Fahrziel", dto.textureNames["1"])
    end)

    it("fallback probes the first ten axis numbers without model metadata", function ()
        local RollingStock = require("ce.hub.data.rollingstock.RollingStock")

        EEPRollingstockSetAxisByNumber("FallbackAxisStock", 7, 42)
        local stock = RollingStock:new({ rollingStockName = "FallbackAxisStock" })
        stock:updateAxisValues()

        assert.equals(42, stock:getAxisValues()["7"])
    end)

    it("reads axis values by localized axis name when ByNumber is unavailable", function ()
        local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
        local RollingStockModelInfo = require("ce.hub.data.rollingstock.RollingStockModelInfo")
        local originalGetAxisByNumber = _G.EEPRollingstockGetAxisByNumber
        local originalEEPLng = _G.EEPLng
        _G.EEPLng = "ENG"
        _G.EEPRollingstockGetAxisByNumber = nil

        EEPRollingstockSetAxis("NameAxisStock", "Driver", 66)
        local stock = RollingStock:new({ rollingStockName = "NameAxisStock" })
        stock.modelInfo = RollingStockModelInfo:new({
            axisNames = { [2] = "Fahrer" },
            axisNamesByLanguage = { ENG = { [2] = "Driver" }, GER = { [2] = "Fahrer" } }
        })
        stock:updateAxisValues()

        _G.EEPRollingstockGetAxisByNumber = originalGetAxisByNumber
        _G.EEPLng = originalEEPLng

        assert.equals(66, stock:getAxisValues()["2"])
    end)

    it("sets axis values by localized axis name when ByNumber is unavailable", function ()
        local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
        local RollingStockModelInfo = require("ce.hub.data.rollingstock.RollingStockModelInfo")
        local originalSetAxisByNumber = _G.EEPRollingstockSetAxisByNumber
        local originalEEPLng = _G.EEPLng
        _G.EEPLng = "ENG"
        _G.EEPRollingstockSetAxisByNumber = nil

        local stock = RollingStock:new({ rollingStockName = "SetNameAxisStock" })
        stock.modelInfo = RollingStockModelInfo:new({
            axisNames = { [2] = "Fahrer" },
            axisNamesByLanguage = { ENG = { [2] = "Driver" }, GER = { [2] = "Fahrer" } }
        })

        assert.is_true(stock:setAxisByNumber(2, 33))
        local ok, value = EEPRollingstockGetAxis("SetNameAxisStock", "Driver")

        _G.EEPRollingstockSetAxisByNumber = originalSetAxisByNumber
        _G.EEPLng = originalEEPLng

        assert.is_true(ok)
        assert.equals(33, value)
    end)

    it("refreshes axis values in the updater for selected rolling stock", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local RollingStockUpdater = require("ce.hub.data.rollingstock.RollingStockUpdater")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        HubOptionsRegistry.setOptions({
            ceTypes = {
                rollingStocks = {
                    ceType = HubCeTypes.RollingStock,
                    discoveryAndUpdate = true,
                    fieldUpdates = { axisValues = "never" }
                }
            }
        })

        EepSimulator.simulateAddTrain("AxisUpdateTrain", "AxisUpdateStock")
        local train = TrainRegistry.forName("AxisUpdateTrain")
        train:setRollingStockCount(1)
        TrainRegistry.setRollingStockNames("AxisUpdateTrain", { ["0"] = "AxisUpdateStock" })
        EEPRollingstockSetAxisByNumber("AxisUpdateStock", 2, 10)

        local stock = RollingStockRegistry.forName("AxisUpdateStock")
        stock:resetDirty()
        InterestSyncRegistry.startSyncFor(HubCeTypes.RollingStock, "AxisUpdateStock")

        EEPRollingstockSetAxisByNumber("AxisUpdateStock", 2, 80)
        RollingStockUpdater.runUpdate()

        assert.equals(80, stock:getAxisValues()["2"])
        assert.is_true(stock.dirtyFields.axisValues)

        InterestSyncRegistry.clearAll()
        HubOptionsRegistry.reset()
    end)
end)

insulate("refresh model by XML model", function ()
    local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
    local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")
    local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")

    RollingStockModels.addModel("MyModel", "MODEL_A.3dm", RollingStockModel:new({ myMarker = "MODEL A" }))
    RollingStockModels.addModel("OtherModel", "MODEL_XML.3dm", RollingStockModel:new({ myMarker = "MODEL XML" }))

    local stock = RollingStockRegistry.forName("MyModel;003")
    stock:setXmlModel("MODEL_XML.3dm")

    it("MODEL XML", function () assert.equals("MODEL XML", stock.model["myMarker"]) end)
end)
