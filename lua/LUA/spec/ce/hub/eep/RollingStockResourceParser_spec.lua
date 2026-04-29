insulate("ce.hub.eep.RollingStockResourceParser", function ()
    local Parser = require("ce.hub.eep.RollingStockResourceParser")

    it("extracts German axis and texture names", function ()
        local info = Parser.parseContent(table.concat({
            '[FileInfo]',
            'MovAxis1_ENG = "driver"',
            'MovAxis2_GER	 = "Fahrer"',
            'TexText1_GER = "1.Fahrziel Vorn"',
            'TexText25_GER = "Verkehrsgesellschaft"'
        }, "\n"))

        assert.equals("Fahrer", info.axisNames[2])
        assert.equals("driver", info.axisNamesByLanguage.ENG[1])
        assert.equals("Fahrer", info.axisNamesByLanguage.GER[2])
        assert.equals("1.Fahrziel Vorn", info.textureNames[1])
        assert.equals("Verkehrsgesellschaft", info.textureNames[25])
        assert.is_nil(info.axisNames[1])
    end)

    it("prints a message and returns empty info for missing ini files", function ()
        local printCalls = {}
        local originalPrint = _G.print
        _G.print = function (message) printCalls[#printCalls + 1] = message end

        local info = Parser.parseFirstExistingFile({
            "not-existing/RollingStockResourceParser_spec.ini",
            "not-existing/RollingStockResourceParser_spec_fallback.ini"
        })

        _G.print = originalPrint

        local expectedMessage = "Rolling stock resource ini file not found: " ..
            "not-existing/RollingStockResourceParser_spec.ini or " ..
            "not-existing/RollingStockResourceParser_spec_fallback.ini"
        assert.equals(expectedMessage, printCalls[1])
        assert.is_nil(next(info.axisNames))
        assert.is_nil(next(info.textureNames))
    end)

    it("resolves ini path below resources rollmaterial", function ()
        local primaryPath, fallbackPath = Parser.iniPathForXmlModel("Schiene/Tram/Wagen.3dm")

        assert.equals("Resourcen\\Rollmaterial\\Schiene\\Tram\\Wagen.ini", primaryPath)
        assert.equals("Resourcen.unp\\Rollmaterial\\Schiene\\Tram\\Wagen.ini", fallbackPath)
    end)

    it("uses the first existing ini path", function ()
        local fallbackPath = "RollingStockResourceParser_spec_fallback.ini"
        local file = assert(io.open(fallbackPath, "w"))
        file:write('MovAxis3_GER = "Tuer"\n')
        file:close()

        local info = Parser.parseFirstExistingFile({
            "not-existing/RollingStockResourceParser_spec.ini",
            fallbackPath
        })

        os.remove(fallbackPath)

        assert.equals("Tuer", info.axisNames[3])
    end)
end)
