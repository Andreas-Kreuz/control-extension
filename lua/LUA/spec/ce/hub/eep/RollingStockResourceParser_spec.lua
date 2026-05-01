insulate("ce.hub.eep.RollingStockResourceParser", function ()
    local Parser = require("ce.hub.eep.RollingStockResourceParser")

    it("extracts German axis and texture names", function ()
        local info = Parser.parseContent(table.concat({
                                                          "[FileInfo]",
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

    it("builds compact visible axis names from ini names", function ()
        local info = Parser.applyVisibleAxisNames(Parser.parseContent(table.concat({
                                                                                       'MovAxis8_GER = "Heckfl\252gel"',
                                                                                       'MovAxis2_GER = "Fahrer"'
                                                                                   }, "\n")))

        assert.equals("Fahrer", info.axisNames[1])
        assert.equals("Heckfl\252gel", info.axisNames[2])
        assert.equals("Fahrer", info.axisNamesByLanguage.GER[1])
        assert.equals("Heckfl\252gel", info.axisNamesByLanguage.GER[2])
        assert.equals("Heckfl\252gel", info.rawAxisNames[8])
    end)

    it("parses structural 3dm axis records", function ()
        local function littleEndianLength(value)
            local length = #value
            return string.char(length % 256, math.floor(length / 256) % 256, 0, 0)
        end

        local function minimal3dmAxisRecord(name)
            local marker = string.char(4, 0, 0, 0, 4, 0, 0, 0)
            local one = string.char(0, 0, 128, 63)
            return marker .. one .. one .. one .. littleEndianLength(name) .. name
        end

        local axes = Parser.parse3dmContent(
            minimal3dmAxisRecord("_internal") .. string.rep("\0", 180) .. minimal3dmAxisRecord("Fahrer"))

        assert.equals(2, #axes)
        assert.equals(1, axes[1].index)
        assert.equals("_internal", axes[1].name)
        assert.is_false(axes[1].isPublic)
        assert.equals(2, axes[2].index)
        assert.equals("Fahrer", axes[2].name)
        assert.is_true(axes[2].isPublic)
    end)

    it("builds compact visible axis names from public 3dm axes when ini has no axes", function ()
        local info = Parser.applyVisibleAxisNames({
            axisNames = {},
            axisNamesByLanguage = {},
            rawAxisNames = {},
            rawAxisNamesByLanguage = {},
            parsed3dmAxes = {
                { index = 12, name = "Schlusstafel_V",      isPublic = true },
                { index = 13, name = "Schlusstafel_H",      isPublic = true },
                { index = 14, name = "Aus-Kohlenstaub_Ein", isPublic = true },
                { index = 15, name = "_internal",           isPublic = false }
            }
        })

        assert.equals("Aus-Kohlenstaub_Ein", info.axisNames[1])
        assert.equals("Schlusstafel_H", info.axisNames[2])
        assert.equals("Schlusstafel_V", info.axisNames[3])
    end)

    it("prints a message and returns empty info for missing ini files", function ()
        local printCalls = {}
        local printStub = stub(_G, "print", function (message) printCalls[#printCalls + 1] = message end)
        finally(function () printStub:revert() end)

        local info = Parser.parseFirstExistingFile({
            "not-existing/RollingStockResourceParser_spec.ini",
            "not-existing/RollingStockResourceParser_spec_fallback.ini"
        })

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
