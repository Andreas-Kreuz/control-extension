insulate("ce.hub.eep.Anl3DiscoveryHelper", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local TEMP_FILE = "spec/ce/hub/eep/_anl3_discovery_helper_tmp.xml"
    local originalEEPLoadData

    local function writeTempXml(content)
        local f = assert(io.open(TEMP_FILE, "w"))
        f:write(content)
        f:close()
        return TEMP_FILE
    end

    local function buildDiscoveryTable(xml)
        originalEEPLoadData = _G.EEPLoadData
        rawset(_G, "EEPLoadData", _G.EEPLoadData or function () return false, nil end)
        clearModule("ce.hub.eep.Anl3DiscoveryHelper")
        clearModule("ce.hub.eep.Anl3ToTable")

        local Anl3ToTable = require("ce.hub.eep.Anl3ToTable")
        local Anl3DiscoveryHelper = require("ce.hub.eep.Anl3DiscoveryHelper")
        local root = assert(Anl3ToTable.loadAnlage(writeTempXml(xml)))
        return Anl3DiscoveryHelper.buildDiscoveryTable(root)
    end

    after_each(function ()
        rawset(_G, "EEPLoadData", originalEEPLoadData)
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
                                                        '<Gleis GleisID="11"><Meldung name="S1" Key_Id="31"/></Gleis>',
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
                                                        '<Rollmaterial name="RS A" typ="STRASSE\\BUS\\A.3dm"/>',
                                                        "</Zugverband>",
                                                        "</Fuhrpark>",
                                                        '<Gebaeudesammlung><Immobile name="#12" gsbname="Haus.3dm"/>',
                                                        '</Gebaeudesammlung>',
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
        assert.equals(44, dt.switches[1].keyId)
        assert.equals("#12", dt.structures[1].name)
        assert.equals("#Train A", dt.trains[1].name)
        assert.equals("road", dt.trains[1].trackType)
        assert.same({ ["33"] = 33 }, dt.trains[1].onTracks)
        assert.equals("RS A", dt.rollingStocks[1].name)
        assert.equals("STRASSE\\BUS\\A.3dm", dt.rollingStocks[1].model)
        assert.equals(0, dt.rollingStocks[1].positionInTrain)
        assert.equals("enter", dt.contacts[1].luaFn)
    end)
end)
