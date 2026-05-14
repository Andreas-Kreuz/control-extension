insulate("ce.hub.util.ProtectedExecution", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.util.ProtectedExecution")
    end)

    it("returns all values from a successful function", function ()
        local ProtectedExecution = require("ce.hub.util.ProtectedExecution")

        local ok, first, second = ProtectedExecution.run("spec.success", function (value)
                                                             return "v" .. value, value * 2
                                                         end, 3)

        assert.is_true(ok)
        assert.equals("v3", first)
        assert.equals(6, second)
    end)

    it("logs traceback and returns false when a function fails", function ()
        local ProtectedExecution = require("ce.hub.util.ProtectedExecution")
        local printedMessages = {}
        local printStub = stub(_G, "print", function (message)
            table.insert(printedMessages, tostring(message))
        end)
        finally(function () printStub:revert() end)

        local ok, err = ProtectedExecution.run("spec.failure", function ()
            error("boom")
        end)

        assert.is_false(ok)
        assert.is_truthy(string.find(err, "boom", 1, true))
        assert.is_truthy(string.find(printedMessages[1], "[#spec.failure] ERROR:", 1, true))
        assert.is_truthy(string.find(printedMessages[1], "stack traceback", 1, true))
    end)
end)
