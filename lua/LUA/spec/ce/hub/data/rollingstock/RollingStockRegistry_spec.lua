insulate("ce.hub.data.rollingstock.RollingStockRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.dynamic.DynamicUpdateRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockStaticDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockDynamicDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        require("ce.hub.eep.EepSimulator")
    end)

    it("collects texture texts sequentially and keeps empty valid surfaces", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local TexturesDtoFactory = require("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EEPRollingstockSetTextureText("RS1", 1, "Line A")
        EEPRollingstockSetTextureText("RS1", 2, "")

        local rollingStock = RollingStockRegistry.forName("RS1")
        local _, _, _, dto = TexturesDtoFactory.createDto(rollingStock)

        assert.same({
                        ceType = "ce.hub.RollingStockTextures",
                        id = "RS1",
                        surfaceTexts = { ["1"] = "Line A", ["2"] = "" }
                    }, dto)
    end)

    it("keeps all rolling stock static entries when only one rolling stock changes", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        local rollingStock1 = RollingStockRegistry.forName("RS1")
        RollingStockRegistry.forName("RS2")

        RollingStockRegistry.fireChangeRollingStockEvents({ [HubCeTypes.RollingStockStatic] = true })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStockStatic, "RS1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStockStatic, "RS2"))

        rollingStock1:setTrainName("T1")
        RollingStockRegistry.fireChangeRollingStockEvents({ [HubCeTypes.RollingStockStatic] = true })

        assert.equals("T1", InternalDataStore.get(HubCeTypes.RollingStockStatic, "RS1").trainName)
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStockStatic, "RS2"))
    end)

    it("sends rolling stock dynamic data only for selected ids", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        local rollingStock1 = RollingStockRegistry.forName("RS1")
        RollingStockRegistry.forName("RS2")

        DynamicUpdateRegistry.startUpdatesFor(HubCeTypes.RollingStockDynamic, "RS1")
        RollingStockRegistry.fireChangeRollingStockEvents({ [HubCeTypes.RollingStockDynamic] = true })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStockDynamic, "RS1"))
        assert.is_nil(InternalDataStore.get(HubCeTypes.RollingStockDynamic, "RS2"))

        rollingStock1:setMileage(1234)
        RollingStockRegistry.fireChangeRollingStockEvents({ [HubCeTypes.RollingStockDynamic] = true })

        assert.equals(1234, InternalDataStore.get(HubCeTypes.RollingStockDynamic, "RS1").mileage)
    end)

    it("emits texture and rotation updates as per-rolling-stock delta changes", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        local removed = {}
        local changed = {}
        DataChangeBus.fireDataRemoved = function (ceType, keyId, key, dto)
            table.insert(removed, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end
        DataChangeBus.fireDataChanged = function (ceType, keyId, key, dto)
            table.insert(changed, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end

        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        local rollingStock = RollingStockRegistry.forName("RS1")
        local secondRollingStock = RollingStockRegistry.forName("RS2")

        rollingStock:setTextureTexts({ ["1"] = "Line A" })
        secondRollingStock:setTextureTexts({ ["1"] = "Line B", ["2"] = "" })
        rollingStock:setRotation(1.234, 2.345, 3.456)
        secondRollingStock:setRotation(4.444, 5.555, 6.666)

        RollingStockRegistry.fireChangeRollingStockEvents({
            [HubCeTypes.RollingStockTextures] = true,
            [HubCeTypes.RollingStockRotation] = true
        })

        local changedByRoomAndKey = {}
        for _, entry in ipairs(changed) do
            changedByRoomAndKey[entry.ceType .. ":" .. entry.key] = entry
        end

        assert.equals(4, #changed)
        assert.same({
                        ceType = "ce.hub.RollingStockTextures",
                        keyId = "id",
                        key = "RS1",
                        dto = {
                            ceType = "ce.hub.RollingStockTextures",
                            id = "RS1",
                            surfaceTexts = { ["1"] = "Line A" }
                        }
                    }, changedByRoomAndKey["ce.hub.RollingStockTextures:RS1"])
        assert.same({
                        ceType = "ce.hub.RollingStockTextures",
                        keyId = "id",
                        key = "RS2",
                        dto = {
                            ceType = "ce.hub.RollingStockTextures",
                            id = "RS2",
                            surfaceTexts = { ["1"] = "Line B", ["2"] = "" }
                        }
                    }, changedByRoomAndKey["ce.hub.RollingStockTextures:RS2"])
        assert.same({
                        ceType = "ce.hub.RollingStockRotation",
                        keyId = "id",
                        key = "RS1",
                        dto = {
                            ceType = "ce.hub.RollingStockRotation",
                            id = "RS1",
                            rotX = 1.23,
                            rotY = 2.35,
                            rotZ = 3.46
                        }
                    }, changedByRoomAndKey["ce.hub.RollingStockRotation:RS1"])
        assert.same({
                        ceType = "ce.hub.RollingStockRotation",
                        keyId = "id",
                        key = "RS2",
                        dto = {
                            ceType = "ce.hub.RollingStockRotation",
                            id = "RS2",
                            rotX = 4.44,
                            rotY = 5.55,
                            rotZ = 6.67
                        }
                    }, changedByRoomAndKey["ce.hub.RollingStockRotation:RS2"])

        rollingStock:setRotation(1.23, 2.35, 3.46)
        RollingStockRegistry.fireChangeRollingStockEvents({ [HubCeTypes.RollingStockRotation] = true })
        assert.equals(4, #changed)

        RollingStockRegistry.rollingStockDisappeared("RS1")

        assert.same({
                        "ce.hub.RollingStockStatic",
                        "ce.hub.RollingStockDynamic",
                        "ce.hub.RollingStockTextures",
                        "ce.hub.RollingStockRotation"
                    }, {
                        removed[1].ceType,
                        removed[2].ceType,
                        removed[3].ceType,
                        removed[4].ceType
                    })
    end)
end)
