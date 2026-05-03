require("ce.hub.eep.EepSimulator")

insulate("ce.hub.data.rollingstock.RollingStockModelRegistry", function ()
    local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")
    local Registry = require("ce.hub.data.rollingstock.RollingStockModelRegistry")

    Registry.addModel("MyModel", "MODEL_A.3dm", RollingStockModel:new({ myMarker = "MODEL A" }))
    Registry.addModel("XmlModel", "MODEL_XML.3dm", RollingStockModel:new({ myMarker = "MODEL XML" }))
    Registry.assignModel("MyModel;005", RollingStockModel:new({ myMarker = "MODEL B" }))

    it("registers by parsed model name", function ()
        assert.equals("MODEL A", Registry.modelFor("MyModel;001")["myMarker"])
    end)

    it("registers by XML model", function ()
        assert.equals("MODEL XML", Registry.modelFor("MyModel;001", "MODEL_XML.3dm")["myMarker"])
    end)

    it("prefers assigned rolling stock models over XML models", function ()
        assert.equals("MODEL B", Registry.modelFor("MyModel;005", "MODEL_XML.3dm")["myMarker"])
    end)

    it("returns a default model for unknown models", function ()
        assert.is_nil(Registry.modelFor("UnknownModel", "UNKNOWN.3dm")["myMarker"])
    end)
end)
