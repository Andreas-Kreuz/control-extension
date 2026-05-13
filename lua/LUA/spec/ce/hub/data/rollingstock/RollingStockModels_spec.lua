require("ce.hub.eep.EepSimulator")

insulate("parse rollingstockname", function ()
    local Models = require("ce.hub.data.rollingstock.RollingStockModels")

    it("MyModel", function () assert.equals("MyModel", Models.parseModelName("MyModel")) end)
    it("MyModel;001", function () assert.equals("MyModel", Models.parseModelName("MyModel;001")) end)
    it("My Model", function () assert.equals("My Model", Models.parseModelName("My Model")) end)
    it("My Model;001", function () assert.equals("My Model", Models.parseModelName("My Model;001")) end)
    it("My (M)odel;;;", function () assert.equals("My (M)odel", Models.parseModelName("My (M)odel;;;")) end)
end)

insulate("find rollingstock model", function ()
    local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")
    local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")

    RollingStockModels.addModel("MyModel", "MODEL_A.3dm", RollingStockModel:new({ myMarker = "MODEL A" }))
    RollingStockModels.addModel("XmlModel", "MODEL_XML.3dm", RollingStockModel:new({ myMarker = "MODEL XML" }))
    RollingStockModels.assignModel("MyModel;005", RollingStockModel:new({ myMarker = "MODEL B" }))

    it("MODEL A", function () assert.equals("MODEL A", RollingStockModels.modelFor("MyModel")["myMarker"]) end)
    it("MODEL A", function () assert.equals("MODEL A", RollingStockModels.modelFor("MyModel;001")["myMarker"]) end)
    it("MODEL XML", function ()
        assert.equals("MODEL XML", RollingStockModels.modelFor("MyModel;001", "MODEL_XML.3dm")["myMarker"])
    end)
    it("MODEL B", function () assert.equals("MODEL B", RollingStockModels.modelFor("MyModel;005")["myMarker"]) end)
    it("MODEL B before XML", function ()
        assert.equals("MODEL B", RollingStockModels.modelFor("MyModel;005", "MODEL_XML.3dm")["myMarker"])
    end)
    it("default model", function ()
        assert.is_nil(RollingStockModels.modelFor("UnknownModel", "UNKNOWN.3dm")["myMarker"])
    end)
end)

insulate("GT4 XML models", function ()
    local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")
    local ModelV15NMA10013 = require("ce.hub.data.rollingstock.ModelV15NMA10013")

    it("finds GT A by XML model", function ()
        assert.equals(ModelV15NMA10013["GT4 Serie 2 (1) Wagen A"],
                      RollingStockModels.modelFor("Unknown", "SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_MA1.3dm"))
    end)

    it("finds GT B by XML model", function ()
        assert.equals(ModelV15NMA10013["GT4 Serie 2 (1) Wagen B"],
                      RollingStockModels.modelFor("Unknown", "SCHIENE\\STRASSENBAHN\\GT4_WG_B_01_W_01_MA1.3dm"))
    end)
end)

insulate("MAN Citybus CR1 display updates", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local textureCalls = {}
    local axisCalls = {}
    local model

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.ModelV15NCR10014")
        textureCalls = {}
        axisCalls = {}
        rawset(_G, "EEPRollingstockSetTextureText", function (rollingStockName, surfaceNumber, text)
            table.insert(textureCalls, {
                rollingStockName = rollingStockName,
                surfaceNumber = surfaceNumber,
                text = text
            })
        end)
        rawset(_G, "EEPRollingstockSetAxis", function (rollingStockName, axisName, axisPosition)
            table.insert(axisCalls, {
                rollingStockName = rollingStockName,
                axisName = axisName,
                axisPosition = axisPosition
            })
        end)
        model = require("ce.hub.data.rollingstock.ModelV15NCR10014")
    end)

    it("sets line, destination, wagon number, and doors on the GL FL bus", function ()
        local citybus = model["MAN Citybus 1 GL FL gelb CR1"]

        citybus:setLine("Bus1", "12")
        citybus:setDestination("Bus1", "Bahnhof")
        citybus:setLicencePlate("Bus1", "DD CE 42")
        citybus:setWagonNumber("Bus1", "1001")
        citybus:setWagonNr("Bus1", "1002")
        citybus:openDoors("Bus1")
        citybus:closeDoors("Bus1")

        assert.same({
                        { rollingStockName = "Bus1", surfaceNumber = 4, text = "12" },
                        { rollingStockName = "Bus1", surfaceNumber = 5, text = "Bahnhof" },
                        { rollingStockName = "Bus1", surfaceNumber = 1, text = "DD CE 42" },
                        { rollingStockName = "Bus1", surfaceNumber = 2, text = "1001" },
                        { rollingStockName = "Bus1", surfaceNumber = 2, text = "1002" },
                    }, textureCalls)
        assert.same({
                        { rollingStockName = "Bus1", axisName = "Tuer1", axisPosition = 100 },
                        { rollingStockName = "Bus1", axisName = "Tuer2", axisPosition = 100 },
                        { rollingStockName = "Bus1", axisName = "Tuer1", axisPosition = 0 },
                        { rollingStockName = "Bus1", axisName = "Tuer2", axisPosition = 0 },
                    }, axisCalls)
    end)

    it("sets all listed doors on the FL bus", function ()
        local citybus = model["MAN Citybus FL gelb CR1"]

        citybus:openDoors("Bus2")

        assert.same({
                        { rollingStockName = "Bus2", axisName = "Tuer1", axisPosition = 100 },
                        { rollingStockName = "Bus2", axisName = "Tuer2", axisPosition = 100 },
                        { rollingStockName = "Bus2", axisName = "Tuer3", axisPosition = 100 },
                    }, axisCalls)
    end)
end)

insulate("MAN Citybus CR1 XML models", function ()
    local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")
    local ModelV15NCR10014 = require("ce.hub.data.rollingstock.ModelV15NCR10014")

    it("finds GLA by EEP-suffixed rolling stock name", function ()
        assert.equals(ModelV15NCR10014["MAN Citybus 1 GLA gelb CR1"],
                      RollingStockModels.modelFor("MAN Citybus 1 GLA gelb CR1;001"))
    end)

    it("finds GL FL by XML model", function ()
        assert.equals(ModelV15NCR10014["MAN Citybus 1 GL FL gelb CR1"],
                      RollingStockModels.modelFor("Unknown", "STRASSE\\BUS\\MAN_CITYBUS_1_GELB_GLFL_CR1.3dm"))
    end)

    it("finds GLA by XML model", function ()
        assert.equals(ModelV15NCR10014["MAN Citybus 1 GLA gelb CR1"],
                      RollingStockModels.modelFor("Unknown", "STRASSE\\BUS\\MAN_CITYBUS_1_GELB_GLA_CR1.3dm"))
    end)
end)

insulate("GT6 8 7ND display updates", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local textureCalls = {}
    local axisCalls = {}
    local model

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.MODELV15NJS20220")
        textureCalls = {}
        axisCalls = {}
        rawset(_G, "EEPRollingstockSetTextureText", function (rollingStockName, surfaceNumber, text)
            table.insert(textureCalls, {
                rollingStockName = rollingStockName,
                surfaceNumber = surfaceNumber,
                text = text
            })
        end)
        rawset(_G, "EEPRollingstockSetAxis", function (rollingStockName, axisName, axisPosition)
            table.insert(axisCalls, {
                rollingStockName = rollingStockName,
                axisName = axisName,
                axisPosition = axisPosition
            })
        end)
        model = require("ce.hub.data.rollingstock.MODELV15NJS20220")
    end)

    it("sets line, destination, origin, next stop, and wagon number textures on wagon 1", function ()
        local wagon = model["GT6_8_7NDWagen1A_JS2"]

        wagon:setLine("Wagen1", "7")
        wagon:setLine("Wagen1", "10")
        wagon:setDestination("Wagen1", "Central")
        wagon:setOrigin("Wagen1", "Depot")
        wagon:setNextStop("Wagen1", "Market")
        wagon:setWagonNumber("Wagen1", "201")
        wagon:setWagonNr("Wagen1", "202")

        assert.same({
                        { rollingStockName = "Wagen1", surfaceNumber = 22, text = "  7  " },
                        { rollingStockName = "Wagen1", surfaceNumber = 22, text = "  10  " },
                        { rollingStockName = "Wagen1", surfaceNumber = 5,  text = "Central" },
                        { rollingStockName = "Wagen1", surfaceNumber = 6,  text = "" },
                        { rollingStockName = "Wagen1", surfaceNumber = 18, text = "Central" },
                        { rollingStockName = "Wagen1", surfaceNumber = 16, text = "Depot" },
                        { rollingStockName = "Wagen1", surfaceNumber = 6,  text = "Market" },
                        { rollingStockName = "Wagen1", surfaceNumber = 17, text = "Market" },
                        { rollingStockName = "Wagen1", surfaceNumber = 23, text = "201" },
                        { rollingStockName = "Wagen1", surfaceNumber = 24, text = "201" },
                        { rollingStockName = "Wagen1", surfaceNumber = 23, text = "202" },
                        { rollingStockName = "Wagen1", surfaceNumber = 24, text = "202" },
                    }, textureCalls)
        assert.same({
                        { rollingStockName = "Wagen1", axisName = "Linie Fahrziel", axisPosition = 100 },
                    }, axisCalls)
    end)

    it("does not set display textures on wagon 3", function ()
        local wagon = model["GT6_8_7NDWagen3_JS2"]

        wagon:setLine("Wagen3", "10")
        wagon:setDestination("Wagen3", "Central")
        wagon:setOrigin("Wagen3", "Depot")
        wagon:setNextStop("Wagen3", "Market")
        wagon:setWagonNr("Wagen3", "201")

        assert.same({}, textureCalls)
        assert.same({}, axisCalls)
    end)
end)

insulate("GT4 destination list display", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local textureCalls = {}
    local model
    local nextStopPrefix = "N" .. string.char(228) .. "chster Halt: "

    before_each(function ()
        clearModule("ce.hub.data.rollingstock.ModelV15NMA10013")
        textureCalls = {}
        rawset(_G, "EEPRollingstockSetTextureText", function (rollingStockName, surfaceNumber, text)
            table.insert(textureCalls, {
                rollingStockName = rollingStockName,
                surfaceNumber = surfaceNumber,
                text = text
            })
        end)
        model = require("ce.hub.data.rollingstock.ModelV15NMA10013")
    end)

    it("rebuilds GT A texture 3 from origin, next stop, and destination", function ()
        local gtA = model["GT4 Serie 2 (1) Wagen A"]

        gtA:setOrigin("GT_A_1", "Depot")
        gtA:setNextStop("GT_A_1", "Market")
        gtA:setDestination("GT_A_1", "Central")

        assert.same({
                        {
                            rollingStockName = "GT_A_1",
                            surfaceNumber = 3,
                            text = "Depot\n" .. nextStopPrefix .. "\n"
                        },
                        {
                            rollingStockName = "GT_A_1",
                            surfaceNumber = 3,
                            text = "Depot\n" .. nextStopPrefix .. "Market\n"
                        },
                        { rollingStockName = "GT_A_1", surfaceNumber = 2, text = "Central" },
                        {
                            rollingStockName = "GT_A_1",
                            surfaceNumber = 3,
                            text = "Depot\n" .. nextStopPrefix .. "Market\nCentral"
                        },
                    }, textureCalls)
    end)

    it("keeps GT A destination list state per rolling stock", function ()
        local gtA = model["GT4 Serie 2 (1) Wagen A"]

        gtA:setOrigin("GT_A_1", "Depot")
        gtA:setOrigin("GT_A_2", "Harbor")
        gtA:setNextStop("GT_A_1", "Market")
        gtA:setDestination("GT_A_2", "Central")

        assert.same({
                        {
                            rollingStockName = "GT_A_1",
                            surfaceNumber = 3,
                            text = "Depot\n" .. nextStopPrefix .. "\n"
                        },
                        {
                            rollingStockName = "GT_A_2",
                            surfaceNumber = 3,
                            text = "Harbor\n" .. nextStopPrefix .. "\n"
                        },
                        {
                            rollingStockName = "GT_A_1",
                            surfaceNumber = 3,
                            text = "Depot\n" .. nextStopPrefix .. "Market\n"
                        },
                        { rollingStockName = "GT_A_2", surfaceNumber = 2, text = "Central" },
                        {
                            rollingStockName = "GT_A_2",
                            surfaceNumber = 3,
                            text = "Harbor\n" .. nextStopPrefix .. "\nCentral"
                        },
                    }, textureCalls)
    end)
end)
