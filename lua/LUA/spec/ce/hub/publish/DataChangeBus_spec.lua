insulate("ce.hub.publish.DataChangeBus", function ()
    local function clearModule(name)
        package.loaded[name] = nil
    end

    before_each(function ()
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")
    end)

    it("supports explicit-key and dto-factory element calls", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local capturedEvents = {}

        DataChangeBus.addListener({
            fireEvent = function (event)
                table.insert(capturedEvents, event)
            end
        })

        DataChangeBus.fireDataAdded("ce.hub.Signal", "id", {
                                      ceType = "ce.hub.Signal",
                                      id = "signal-a",
                                      name = "Alpha"
                                  })
        DataChangeBus.fireDataChanged("ce.hub.Signal", "id", "signal-b", { ceType = "ce.hub.Signal", status = "go" })

        assert.equals(DataChangeBus.eventType.completeReset, capturedEvents[1].type)
        assert.equals(DataChangeBus.eventType.dataAdded, capturedEvents[2].type)
        assert.same({ ceType = "ce.hub.Signal", id = "signal-a", name = "Alpha" }, capturedEvents[2].payload.element)
        assert.equals(DataChangeBus.eventType.dataChanged, capturedEvents[3].type)
        assert.same({ ceType = "ce.hub.Signal", id = "signal-b", status = "go" }, capturedEvents[3].payload.element)
    end)

    it("validates an explicit key against the element", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")

        assert.has_error(function ()
                             DataChangeBus.fireDataRemoved("ce.hub.Signal", "id", "signal-a", {
                                                         ceType = "ce.hub.Signal",
                                                         id = "signal-b"
                                                     })
                         end, "the key must match element[keyId]")
    end)
end)
