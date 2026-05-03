insulate("ce.hub.eep.RollingStockResourceParser", function ()
    local Parser = require("ce.hub.eep.RollingStockResourceParser")
    local marker = string.char(4, 0, 0, 0, 4, 0, 0, 0)
    local one = string.char(0, 0, 128, 63)

    local function littleEndianLength(value)
        local length = #value
        return string.char(length % 256, math.floor(length / 256) % 256, 0, 0)
    end

    local function minimal3dmAxisRecord(name)
        return marker .. one .. one .. one .. littleEndianLength(name) .. name
    end

    local function minimal3dm0aControlRecord(name)
        return string.char(10, 0, 0, 0) ..
            marker ..
            string.rep("\0", 80) ..
            littleEndianLength(name) ..
            name
    end

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

    it("builds compact visible axis names from ini source order", function ()
        local info = Parser.applyVisibleAxisNames(Parser.parseContent(table.concat({
                                                                                       'MovAxis8_GER = "Heckfl\252gel"',
                                                                                       'MovAxis2_GER = "Fahrer"'
                                                                                   }, "\n")))

        assert.equals("Fahrer", info.axisNames[1])
        assert.equals("Heckfl\252gel", info.axisNames[2])
        assert.is_true(info.axisNamesKnown)
        assert.equals("Fahrer", info.axisNamesByLanguage.GER[1])
        assert.equals("Heckfl\252gel", info.axisNamesByLanguage.GER[2])
        assert.equals("Heckfl\252gel", info.rawAxisNames[8])
    end)

    it("keeps MAN Citybus axis numbers independent from alphabetical display order", function ()
        local info = Parser.applyVisibleAxisNames(Parser.parseContent(table.concat({
                                                                                       'MovAxis1_GER = "Passagiere"',
                                                                                       'MovAxis2_GER = "Fahrer"',
                                                                                       'MovAxis3_GER = "Tuer1"',
                                                                                       'MovAxis4_GER = "Tuer2"'
                                                                                   }, "\n")))

        assert.equals("Passagiere", info.axisNames[1])
        assert.equals("Fahrer", info.axisNames[2])
        assert.equals("Tuer1", info.axisNames[3])
        assert.equals("Tuer2", info.axisNames[4])
        assert.is_true(info.axisNamesKnown)
    end)

    it("compacts B747 axis numbers from raw MovAxis source order", function ()
        local content = table.concat({
                                         'MovAxis04_GER = "Rollen-li-re"',
                                         'MovAxis05_GER = "Neigen"',
                                         'MovAxis08_GER = "Landelicht-Aus-Ein"',
                                         'MovAxis11_GER = "LK-HR-Zu-Auf"',
                                         'MovAxis12_GER = "LK-VR-Zu-Auf"',
                                         'MovAxis13_GER = "Fahrwerk-Ab-Auf"',
                                         'MovAxis25_GER = "Flaps-0-30"',
                                         'MovAxis32_GER = "Bremsklappen-Ab-Auf"',
                                         'MovAxis47_GER = "Pos-Light-Aus-Ein"',
                                         'MovAxis50_GER = "Bodenlicht-Aus-Ein"',
                                         'MovAxis59_GER = "Logo-Lights-Aus-Ein"',
                                         'MovAxis60_GER = "Strobe-Lights-Aus-Ein"',
                                         'MovAxis79_GER = "Triebwerke-Aus-Ein"'
                                     }, "\n")
        local info = Parser.applyVisibleAxisNames(Parser.parseContent(content))

        assert.equals("Rollen-li-re", info.axisNames[1])
        assert.equals("Neigen", info.axisNames[2])
        assert.equals("Bodenlicht-Aus-Ein", info.axisNames[10])
        assert.equals("Triebwerke-Aus-Ein", info.axisNames[13])
        assert.equals("Rollen-li-re", info.rawAxisNames[4])
        assert.is_true(info.axisNamesKnown)
    end)

    it("parses structural 3dm axis records", function ()
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

    it("parses 0A 3dm control records into merged diagnostics", function ()
        local axes, controls = Parser.parse3dmContent(
            minimal3dmAxisRecord("Heckklappe") ..
            string.rep("\0", 180) ..
            minimal3dm0aControlRecord("Warnleuchte aus"))

        assert.equals(1, #axes)
        assert.equals(2, #controls)
        assert.equals("Heckklappe", controls[1].name)
        assert.is_true(controls[1].recordTypes["09"])
        assert.equals("Warnleuchte aus", controls[2].name)
        assert.is_true(controls[2].recordTypes["0A"])
    end)

    it("builds compact visible axis names from public 3dm source order when ini has no axes", function ()
        local info = Parser.applyVisibleAxisNames({
            axisNames = {},
            axisNamesByLanguage = {},
            rawAxisNames = {},
            rawAxisNamesByLanguage = {},
            parsed3dmAxesKnown = true,
            parsed3dmAxes = {
                { index = 12, name = "Schlusstafel_V",      isPublic = true },
                { index = 13, name = "Schlusstafel_H",      isPublic = true },
                { index = 14, name = "Aus-Kohlenstaub_Ein", isPublic = true },
                { index = 15, name = "_internal",           isPublic = false }
            }
        })

        assert.equals("Schlusstafel_V", info.axisNames[1])
        assert.equals("Schlusstafel_H", info.axisNames[2])
        assert.equals("Aus-Kohlenstaub_Ein", info.axisNames[3])
        assert.is_true(info.axisNamesKnown)
    end)

    it("uses merged 0A-only 3dm controls when ini has no axes", function ()
        local _, controls = Parser.parse3dmContent(
            minimal3dmAxisRecord("Zu<Klappen>Auf") ..
            string.rep("\0", 180) ..
            minimal3dmAxisRecord("Schlusstafel_V") ..
            string.rep("\0", 180) ..
            minimal3dmAxisRecord("Schlusstafel_H") ..
            string.rep("\0", 180) ..
            minimal3dmAxisRecord("Aus-Kohlenstaub_Ein") ..
            string.rep("\0", 180) ..
            minimal3dm0aControlRecord("Voll-Ladung-Leer"))

        local info = Parser.applyVisibleAxisNames({
            axisNames = {},
            axisNamesByLanguage = {},
            rawAxisNames = {},
            rawAxisNamesByLanguage = {},
            parsed3dmAxesKnown = true,
            parsed3dmControls = controls
        })

        assert.equals("Zu<Klappen>Auf", info.axisNames[1])
        assert.equals("Schlusstafel_V", info.axisNames[2])
        assert.equals("Schlusstafel_H", info.axisNames[3])
        assert.equals("Aus-Kohlenstaub_Ein", info.axisNames[4])
        assert.equals("Voll-Ladung-Leer", info.axisNames[5])
        assert.is_true(info.axisNamesKnown)
    end)

    it("uses 3dm source order for ini axes that only differ by case", function ()
        local info = Parser.parseContent(table.concat({
                                                          'MovAxis1_GER = "fahrer"',
                                                          'MovAxis2_GER = "Taxi_Licht"'
                                                      }, "\n"))
        local _, controls = Parser.parse3dmContent(
            minimal3dmAxisRecord("Taxi_Licht") ..
            string.rep("\0", 180) ..
            minimal3dm0aControlRecord("Fahrer"))
        info.parsed3dmControls = controls

        info = Parser.applyVisibleAxisNames(info)

        assert.equals("Taxi_Licht", info.axisNames[1])
        assert.equals("Fahrer", info.axisNames[2])
        assert.equals("ini+3dm", info.visibleAxisInfos[2].source)
        assert.is_true(info.visibleAxisInfos[2].caseOnlyMatch)
    end)

    it("keeps unmatched ini axes visible after 3dm-matched axes", function ()
        local info = Parser.parseContent(table.concat({
                                                          'MovAxis2_GER = "Hydraulischer Arm"',
                                                          'MovAxis3_GER = "Gleitarm"',
                                                          'MovAxis14_GER = "Treiber"'
                                                      }, "\n"))
        local _, controls = Parser.parse3dmContent(minimal3dm0aControlRecord("Driver"))
        info.parsed3dmControls = controls

        info = Parser.applyVisibleAxisNames(info)

        assert.equals("Hydraulischer Arm", info.axisNames[1])
        assert.equals("Gleitarm", info.axisNames[2])
        assert.equals("Treiber", info.axisNames[3])
    end)

    it("keeps ADAC public 3dm axis numbers independent from alphabetical display order", function ()
        local info = Parser.applyVisibleAxisNames({
            axisNames = {},
            axisNamesByLanguage = {},
            rawAxisNames = {},
            rawAxisNamesByLanguage = {},
            parsed3dmAxesKnown = true,
            parsed3dmAxes = {
                { index = 6,  name = "Fahrer",             isPublic = true },
                { index = 7,  name = "Blinklicht",         isPublic = true },
                { index = 12, name = "Bruecke_heben",      isPublic = true },
                { index = 14, name = "Kran_drehen",        isPublic = true },
                { index = 15, name = "Kran-Arm_1",         isPublic = true },
                { index = 16, name = "Kran-Arm_2",         isPublic = true },
                { index = 17, name = "Kran_ausfahren",     isPublic = true },
                { index = 28, name = "Stuetzen_ausfahren", isPublic = true },
                { index = 29, name = "Stuetzen_runter",    isPublic = true }
            }
        })

        assert.equals("Fahrer", info.axisNames[1])
        assert.equals("Blinklicht", info.axisNames[2])
        assert.equals("Bruecke_heben", info.axisNames[3])
        assert.equals("Kran_drehen", info.axisNames[4])
        assert.equals("Kran-Arm_1", info.axisNames[5])
        assert.equals("Kran-Arm_2", info.axisNames[6])
        assert.equals("Kran_ausfahren", info.axisNames[7])
        assert.equals("Stuetzen_ausfahren", info.axisNames[8])
        assert.equals("Stuetzen_runter", info.axisNames[9])
        assert.is_true(info.axisNamesKnown)
    end)

    it("marks axis names known when the parsed 3dm model has no public axes", function ()
        local info = Parser.applyVisibleAxisNames({
            axisNames = {},
            axisNamesByLanguage = {},
            rawAxisNames = {},
            rawAxisNamesByLanguage = {},
            parsed3dmAxesKnown = true,
            parsed3dmAxes = {}
        })

        assert.is_nil(next(info.axisNames))
        assert.is_true(info.axisNamesKnown)
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
        assert.is_false(info.axisNamesKnown)
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
