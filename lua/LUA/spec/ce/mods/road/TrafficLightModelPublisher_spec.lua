insulate("ce.mods.road.data.TrafficLightModelPublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.IncrementalListPublisher")
        clearModule("ce.mods.road.data.RoadCeTypes")
        clearModule("ce.mods.road.data.TrafficLightModelDtoFactory")
        clearModule("ce.mods.road.data.TrafficLightModelPublisher")
        clearModule("ce.mods.road.data.TrafficLightModelStatePublisher")
    end)

    local function installFactory(list)
        package.loaded["ce.mods.road.data.TrafficLightModelDtoFactory"] = {
            createTrafficLightModelDtoListFromModels = function ()
                return "ce.mods.road.TrafficLightModel", "id", list
            end
        }
    end

    it("publishes static traffic light models only once while unchanged", function ()
        installFactory({
            { ceType = "ce.mods.road.TrafficLightModel", id = "road", name = "road" }
        })
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local TrafficLightModelPublisher = require("ce.mods.road.data.TrafficLightModelPublisher")
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

        TrafficLightModelPublisher.syncState()
        TrafficLightModelPublisher.syncState()

        assert.equals(1, #listChanges)
        assert.equals(0, #dataChanges)
    end)

    it("publishes a new baseline after full sync is requested", function ()
        installFactory({
            { ceType = "ce.mods.road.TrafficLightModel", id = "road", name = "road" }
        })
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local TrafficLightModelStatePublisher = require("ce.mods.road.data.TrafficLightModelStatePublisher")
        local listChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            table.insert(listChanges, { ceType = ceType, keyId = keyId, list = list })
        end)
        finally(function () fireListChangeStub:revert() end)

        TrafficLightModelStatePublisher.syncState()
        TrafficLightModelStatePublisher.requestFullSync()
        TrafficLightModelStatePublisher.syncState()

        assert.equals(2, #listChanges)
    end)
end)
