insulate("ce.mods.transit.data.TransitTrainPublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.mods.transit.data.TransitTrain")
        clearModule("ce.mods.transit.data.TransitTrainDtoFactory")
        clearModule("ce.mods.transit.data.TransitTrainPublisher")
        clearModule("ce.mods.transit.data.TransitTrainRegistry")
        clearModule("ce.mods.transit.options.TransitOptionsRegistry")
    end)

    local function createTransitTrain(trainId)
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
        local hubTrain = {
            id = trainId,
            type = "Train",
            setValue = function () end
        }
        return TransitTrainRegistry.forTrain(hubTrain)
    end

    it("publishes a baseline list and then no unchanged transit train updates", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local TransitTrainPublisher = require("ce.mods.transit.data.TransitTrainPublisher")
        local listChanges = {}
        local dataChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            table.insert(listChanges, { ceType = ceType, keyId = keyId, list = list })
        end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(dataChanges, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)

        createTransitTrain("T1"):updateLine("10")
        createTransitTrain("T2"):updateLine("11")

        TransitTrainPublisher.syncState()
        TransitTrainPublisher.syncState()

        assert.equals(1, #listChanges)
        assert.equals(2, #listChanges[1].list)
        assert.equals(0, #dataChanges)
    end)

    it("publishes changed transit train fields as patches", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local TransitTrainPublisher = require("ce.mods.transit.data.TransitTrainPublisher")
        local dataChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function () end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(dataChanges, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)

        local transitTrain = createTransitTrain("T1")

        TransitTrainPublisher.syncState()
        transitTrain:updateDestination("Central")
        TransitTrainPublisher.syncState()

        assert.equals(1, #dataChanges)
        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        destination = "Central"
                    }, dataChanges[1].dto)
    end)

    it("publishes full-sync requests as a single transit train list baseline", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local TransitTrainPublisher = require("ce.mods.transit.data.TransitTrainPublisher")
        local listChanges = {}
        local dataChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            table.insert(listChanges, { ceType = ceType, keyId = keyId, list = list })
        end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(dataChanges, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)

        createTransitTrain("T1")

        TransitTrainPublisher.syncState()
        TransitTrainPublisher.requestFullSync()
        TransitTrainPublisher.syncState()

        assert.equals(2, #listChanges)
        assert.equals(0, #dataChanges)
    end)
end)
