insulate("ce.hub.data.switches.SwitchDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.switches.SwitchDtoFactory")
    end)

    it("projects switches to detached DTO tables", function ()
        local SwitchDtoFactory = require("ce.hub.data.switches.SwitchDtoFactory")
        local switch = { id = 11, position = 1, tag = "Main" }

        local ceType, keyId, key, switchDto = SwitchDtoFactory.createSwitchDto(switch)
        switch.tag = "Changed"

        assert.equals("ce.hub.Switch", ceType)
        assert.equals("id", keyId)
        assert.equals(11, key)
        assert.same({ ceType = "ce.hub.Switch", id = 11, position = 1, tag = "Main" }, switchDto)
    end)
end)
