insulate("ce.hub.publish.IncrementalListPublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.publish.IncrementalListPublisher")
        clearModule("ce.hub.publish.DataChangeBus")
    end)

    it("publishes a baseline list and then only changed fields", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
        local publisher = IncrementalListPublisher:new()
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

        publisher:publish("ce.test.Item", "id", {
            { ceType = "ce.test.Item", id = "a", name = "A", count = 1 }
        })
        publisher:publish("ce.test.Item", "id", {
            { ceType = "ce.test.Item", id = "a", name = "A", count = 2 }
        })

        assert.equals(1, #listChanges)
        assert.equals(1, #dataChanges)
        assert.same({
                        ceType = "ce.test.Item",
                        id = "a",
                        count = 2
                    }, dataChanges[1].dto)
    end)
end)
