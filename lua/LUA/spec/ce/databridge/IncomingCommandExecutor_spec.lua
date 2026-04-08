insulate("ce.databridge.IncomingCommandExecutor", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPRollingstockSetActive
    local originalEEPActivateCtrlDesk
    local originalEEPShowInfoTextBottom
    local originalEEPShowInfoTextTop

    before_each(function ()
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")

        originalEEPRollingstockSetActive = _G.EEPRollingstockSetActive
        originalEEPActivateCtrlDesk = _G.EEPActivateCtrlDesk
        originalEEPShowInfoTextBottom = _G.EEPShowInfoTextBottom
        originalEEPShowInfoTextTop = _G.EEPShowInfoTextTop
    end)

    after_each(function ()
        rawset(_G, "EEPRollingstockSetActive", originalEEPRollingstockSetActive)
        rawset(_G, "EEPActivateCtrlDesk", originalEEPActivateCtrlDesk)
        rawset(_G, "EEPShowInfoTextBottom", originalEEPShowInfoTextBottom)
        rawset(_G, "EEPShowInfoTextTop", originalEEPShowInfoTextTop)
    end)

    it("allows explicit EEP commands outside the EEP*Set naming pattern", function ()
        local IncomingCommandExecutor
        local rollingstockCalls = 0
        local ctrlDeskCalls = 0
        local bottomCalls = 0
        local topCalls = 0

        rawset(_G, "EEPRollingstockSetActive", function ()
            rollingstockCalls = rollingstockCalls + 1
            return true
        end)
        rawset(_G, "EEPActivateCtrlDesk", function ()
            ctrlDeskCalls = ctrlDeskCalls + 1
            return true
        end)
        rawset(_G, "EEPShowInfoTextBottom", function ()
            bottomCalls = bottomCalls + 1
            return true
        end)
        rawset(_G, "EEPShowInfoTextTop", function ()
            topCalls = topCalls + 1
            return true
        end)

        clearModule("ce.databridge.IncomingCommandExecutor")
        IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")

        IncomingCommandExecutor.executeIncomingCommands("EEPRollingstockSetActive|BR 218")
        IncomingCommandExecutor.executeIncomingCommands("EEPActivateCtrlDesk|Desk 1")
        IncomingCommandExecutor.executeIncomingCommands("EEPShowInfoTextBottom|1|2|3|4|5|6|Bottom")
        IncomingCommandExecutor.executeIncomingCommands("EEPShowInfoTextTop|1|2|3|4|5|6|Top")

        assert.equals(1, rollingstockCalls)
        assert.equals(1, ctrlDeskCalls)
        assert.equals(1, bottomCalls)
        assert.equals(1, topCalls)
    end)
end)
