insulate("ce.hub.eep.scenario.EepScenarioAnl3Discovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local TEMP_FILE = "spec/ce/hub/eep/_anl3_discovery_helper_tmp.xml"
    local originalEEPLoadData
    local originalEEPLng

    before_each(function ()
        originalEEPLng = _G.EEPLng
    end)

    local function writeTempXml(content)
        local f = assert(io.open(TEMP_FILE, "w"))
        f:write(content)
        f:close()
        return TEMP_FILE
    end

    local function buildDiscoveryTable(xml)
        originalEEPLoadData = _G.EEPLoadData
        rawset(_G, "EEPLoadData", _G.EEPLoadData or function () return false, nil end)
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        clearModule("ce.hub.eep.scenario.EepScenarioAnl3Parser")

        local EepScenarioAnl3Parser = require("ce.hub.eep.scenario.EepScenarioAnl3Parser")
        local EepScenarioAnl3Discovery = require("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
        local root = assert(EepScenarioAnl3Parser.loadAnlage(writeTempXml(xml)))
        return EepScenarioAnl3Discovery.buildDiscoveryTable(root)
    end

    after_each(function ()
        rawset(_G, "EEPLoadData", originalEEPLoadData)
        rawset(_G, "EEPLng", originalEEPLng)
        clearModule("ce.hub.eep.resources.StructureResourceParser")
        os.remove(TEMP_FILE)
    end)

    it("extracts static topology and coverage from anl3", function ()
        local dt = buildDiscoveryTable(table.concat({
                                                        '<?xml version="1.0" encoding="UTF-8"?>',
                                                        "<sutrackp>",
                                                        '<Options RouteItems="1" RouteId_0="7" RouteName_0="Linie 7"/>',
                                                        '<Kammerasammlung cnt="2">',
                                                        '<Kammera name="Bahnhof" Dynamic="0"/>',
                                                        '<Kammera name="Fahrtwind" Dynamic="1"/>',
                                                        "</Kammerasammlung>",
                                                        '<Gleissystem GleissystemID="1" TrackSystemNumber="1">',
                                                        '<Gleis GleisID="11"><Meldung name="S1" Key_Id="31"' ..
                                                        ' LuaTag="s1tag," TipTxt="Signal 1" TipShow="1"/></Gleis>',
                                                        "</Gleissystem>",
                                                        '<Gleissystem GleissystemID="2" TrackSystemNumber="2">',
                                                        '<Gleis GleisID="22"/></Gleissystem>',
                                                        '<Gleissystem GleissystemID="3" TrackSystemNumber="3">',
                                                        '<Gleis GleisID="33" Key_Id="44" weichenstellung="2">',
                                                        '<Kontakt LuaFn="enter" TipTxt="Enter"/>',
                                                        "</Gleis>",
                                                        "</Gleissystem>",
                                                        '<Gleissystem GleissystemID="4" TrackSystemNumber="4">',
                                                        '<Gleis GleisID="55"/></Gleissystem>',
                                                        '<Gleissystem GleissystemID="5" type="Steuerstrecken">',
                                                        '<Gleis GleisID="66"/></Gleissystem>',
                                                        '<Fuhrpark FuhrparkID="1">',
                                                        '<Zugverband name="#Train A" Route="7" Geschwindigkeit="12"',
                                                        ' sollgeschwindigkeit="20"',
                                                        ' kupplungvorn="1" kupplunghinten="2">',
                                                        '<Gleisort gleissystemID="3" gleisID="33" parameter="456.7"',
                                                        ' ausrichtung="1"/>',
                                                        '<Rollmaterial name="RS A" typ="STRASSE\\BUS\\A.3dm"' ..
                                                        ' LuaTag="line=7," Smoke="0">',
                                                        "<Text3DM>",
                                                        '<TexText Idx="0" Text="7"/>',
                                                        '<TexText Idx="4" Text="Zentrum"/>',
                                                        "</Text3DM>",
                                                        "</Rollmaterial>",
                                                        "</Zugverband>",
                                                        "</Fuhrpark>",
                                                        "<Gebaeudesammlung>",
                                                        '<Immobile name="#12" gsbname="Haus.3dm"',
                                                        ' LuaTag="p1=#4," Light="1" Smoke="100" Fire="0"' ..
                                                        ' TipTxt="Info #12" TipShow="1">',
                                                        "<Dreibein>",
                                                        '<Vektor x="10000" y="20000" z="300"/>',
                                                        '<Vektor x="0" y="1" z="0"/>',
                                                        '<Vektor x="-1" y="0" z="0"/>',
                                                        '<Vektor x="0" y="0" z="1"/>',
                                                        "</Dreibein>",
                                                        "<Text3DM>",
                                                        '<TexText Idx="20" Text="Hauptbahnhof"/>',
                                                        '<TexText Idx="23" Text="Steig 1"/>',
                                                        "</Text3DM>",
                                                        "</Immobile>",
                                                        '<Immobile ImmoIdx="13" gsbname="Baum.3dm"' ..
                                                        ' Light="0" Smoke="0" Fire="0"/>',
                                                        "</Gebaeudesammlung>",
                                                        '<EEPLua LUAPath="\\Topology.lua"/>',
                                                        "</sutrackp>"
                                                    }, ""))

        assert.is_true(dt.coverage.scenario)
        assert.is_true(dt.coverage.routes)
        assert.is_true(dt.coverage.tracks)
        assert.is_true(dt.coverage.trains)
        assert.is_true(dt.coverage.rollingStocks)
        assert.is_true(dt.coverage.structures)
        assert.is_true(dt.coverage.signals)
        assert.is_true(dt.coverage.switches)
        assert.is_true(dt.coverage.contacts)
        assert.same({ "Bahnhof" }, dt.cameras.static)
        assert.same({ "Fahrtwind" }, dt.cameras.dynamic)
        assert.equals("Linie 7", dt.routes[1].name)
        assert.equals(11, dt.tracks.rail[1].id)
        assert.equals(22, dt.tracks.tram[1].id)
        assert.equals(33, dt.tracks.road[1].id)
        assert.equals(55, dt.tracks.auxiliary[1].id)
        assert.equals(66, dt.tracks.control[1].id)
        assert.equals(31, dt.signals[1].keyId)
        assert.equals("s1tag,", dt.signals[1].tag)
        assert.equals("Signal 1", dt.signals[1].tipTxt)
        assert.is_true(dt.signals[1].tipShow)
        assert.equals(44, dt.switches[1].keyId)
        assert.equals("#12", dt.structures[1].name)
        assert.equals("p1=#4,", dt.structures[1].tag)
        assert.equals("Info #12", dt.structures[1].tipTxt)
        assert.is_true(dt.structures[1].tipShow)
        assert.is_true(dt.structures[1].light)
        assert.is_true(dt.structures[1].smoke)
        assert.is_false(dt.structures[1].fire)
        assert.equals("Hauptbahnhof", dt.structures[1].textureTexts["21"])
        assert.equals("Steig 1", dt.structures[1].textureTexts["24"])
        assert.same(100.0, dt.structures[1].pos_x)
        assert.same(200.0, dt.structures[1].pos_y)
        assert.same(3.0, dt.structures[1].pos_z)
        assert.same(0.0, dt.structures[1].rot_x)
        assert.same(0.0, dt.structures[1].rot_y)
        assert.same(90.0, dt.structures[1].rot_z)
        assert.equals("#13", dt.structures[2].id)
        assert.equals("#13", dt.structures[2].name)
        assert.equals("Baum.3dm", dt.structures[2].gsbname)
        assert.is_false(dt.structures[2].light)
        assert.is_false(dt.structures[2].smoke)
        assert.is_false(dt.structures[2].fire)
        assert.is_nil(dt.structures[2].pos_x)
        assert.equals("#Train A", dt.trains[1].name)
        assert.equals("road", dt.trains[1].trackType)
        assert.same({ ["33"] = 33 }, dt.trains[1].onTracks)
        assert.equals("RS A", dt.rollingStocks[1].name)
        assert.equals("STRASSE\\BUS\\A.3dm", dt.rollingStocks[1].model)
        assert.equals(0, dt.rollingStocks[1].positionInTrain)
        assert.equals("line=7,", dt.rollingStocks[1].tag)
        assert.same(0, dt.rollingStocks[1].smoke)
        assert.equals("7", dt.rollingStocks[1].textureTexts["1"])
        assert.equals("Zentrum", dt.rollingStocks[1].textureTexts["5"])
        assert.equals("enter", dt.contacts[1].luaFn)
    end)

    it("builds Lua structure names from ImmoIdx and localized model ini names", function ()
        local calls = 0
        rawset(_G, "EEPLng", "ENG")
        package.loaded["ce.hub.eep.resources.StructureResourceParser"] = {
            infoForGsbname = function (gsbname)
                calls = calls + 1
                assert.equals("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm", gsbname)
                return {
                    modelNamesByLanguage = {
                        ENG = "Tram Signal casing Mast 4",
                        GER = "Straba Signal Geh\228use Mast 4"
                    }
                }
            end,
            modelNameForLanguage = function (info, language)
                return info.modelNamesByLanguage[language] or info.modelNamesByLanguage.GER
            end
        }

        local dt = buildDiscoveryTable(table.concat({
                                                        '<?xml version="1.0" encoding="UTF-8"?>',
                                                        "<sutrackp><Gebaeudesammlung>",
                                                        '<Immobile ImmoIdx="3026"',
                                                        ' gsbname="\\Immobilien\\Verkehr\\Signale\\' ..
                                                        'StrabaSigGM_4_MA1.3dm"/>',
                                                        '<Immobile ImmoIdx="3027"',
                                                        ' gsbname="\\Immobilien\\Verkehr\\Signale\\' ..
                                                        'StrabaSigGM_4_MA1.3dm"/>',
                                                        "</Gebaeudesammlung></sutrackp>"
                                                    }, ""))

        assert.equals("#3026", dt.structures[1].id)
        assert.equals("#3026_Tram Signal casing Mast 4", dt.structures[1].name)
        assert.equals("#3027", dt.structures[2].id)
        assert.equals("#3027_Tram Signal casing Mast 4", dt.structures[2].name)
        assert.equals(1, calls)
    end)

    it("falls back to German model names for unknown EEP languages", function ()
        local requestedLanguage
        rawset(_G, "EEPLng", "ITA")
        package.loaded["ce.hub.eep.resources.StructureResourceParser"] = {
            infoForGsbname = function ()
                return {
                    modelNamesByLanguage = {
                        GER = "Straba Signal Geh\228use Mast 4"
                    }
                }
            end,
            modelNameForLanguage = function (info, language)
                requestedLanguage = language
                return info.modelNamesByLanguage[language] or info.modelNamesByLanguage.GER
            end
        }

        local dt = buildDiscoveryTable(table.concat({
                                                        '<?xml version="1.0" encoding="UTF-8"?>',
                                                        "<sutrackp><Gebaeudesammlung>",
                                                        '<Immobile ImmoIdx="3026" gsbname="Signal.3dm"/>',
                                                        "</Gebaeudesammlung></sutrackp>"
                                                    }, ""))

        assert.equals("GER", requestedLanguage)
        assert.equals("#3026_Straba Signal Geh\228use Mast 4", dt.structures[1].name)
    end)
end)
