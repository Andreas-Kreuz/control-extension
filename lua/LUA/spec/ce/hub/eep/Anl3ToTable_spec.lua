local Anl3ToTable = require("ce.hub.eep.Anl3ToTable")

local TEMP_FILE = "spec/ce/hub/eep/_anl3_test_tmp.xml"

local function writeTempXml(content)
    local f = assert(io.open(TEMP_FILE, "w"))
    f:write(content)
    f:close()
    return TEMP_FILE
end

local function load(xmlPath)
    local result = Anl3ToTable.loadAnlage(xmlPath)
    assert(result, "loadAnlage returned nil")
    return result
end

local function findChild(node, tag)
    for _, child in ipairs(node.children) do
        if child.tag == tag then return child end
    end
    return nil
end

local function findAll(node, tag)
    local result = {}
    for _, child in ipairs(node.children) do
        if child.tag == tag then result[#result + 1] = child end
        for _, found in ipairs(findAll(child, tag)) do result[#result + 1] = found end
    end
    return result
end

local MINIMAL_ANL3 = table.concat({
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<sutrackp>',
    '<Version EEP="18" Language="GER"/>',
    '<Fuhrpark FuhrparkID="1">',
    '<Zugverband ZugID="1" name="ICE 1">',
    '<Rollmaterial name="ICE 1 Lok" typ="\\Fahrzeuge\\ICE1.3dm">',
    '</Rollmaterial>',
    '</Zugverband>',
    '</Fuhrpark>',
    '<Kammerasammlung cnt="2">',
    '<Kammera name="Bahnhof" Dynamic="0"/>',
    '<Kammera name="Fahrtwind" Dynamic="1"/>',
    '</Kammerasammlung>',
    '<Gleissystem GleissystemID="3">',
    '<Gleis GleisID="1">',
    '<Kontakt LuaFn="einfahrt" TipTxt="Einfahrt" Position="100"/>',
    '<Meldung name="Signal 1" Key_Id="5"/>',
    '<Dreibein><Vektor x="0" y="0" z="0">Pos</Vektor></Dreibein>',
    '</Gleis>',
    '</Gleissystem>',
    '<EEPLua LUAPath="\\Meine-Anlage.lua"/>',
    '</sutrackp>',
}, "")

insulate("Anl3ToTable", function ()
    local path

    before_each(function ()
        path = writeTempXml(MINIMAL_ANL3)
    end)

    after_each(function ()
        os.remove(path)
    end)

    it("returns nil and error message when file does not exist", function ()
        local result, err = Anl3ToTable.loadAnlage("/nonexistent/file.anl3")
        assert.is_nil(result)
        assert.is_not_nil(err)
    end)

    it("returns the root element as the document root", function ()
        local root = load(path)
        assert.equals("sutrackp", root.tag)
    end)

    it("parses element attributes", function ()
        local root = load(path)
        local version = assert(findChild(root, "Version"))
        assert.equals("18", version.attrs.EEP)
        assert.equals("GER", version.attrs.Language)
    end)

    it("builds child arrays for nested elements", function ()
        local root = load(path)
        local fuhrpark = assert(findChild(root, "Fuhrpark"))
        assert.equals("1", fuhrpark.attrs.FuhrparkID)
        local zugverband = assert(findChild(fuhrpark, "Zugverband"))
        assert.equals("ICE 1", zugverband.attrs.name)
    end)

    it("handles self-closing tags as leaf nodes with no children", function ()
        local root = load(path)
        local eepLua = assert(findChild(root, "EEPLua"))
        assert.equals("\\Meine-Anlage.lua", eepLua.attrs.LUAPath)
        assert.equals(0, #eepLua.children)
    end)

    it("captures text content in the text field", function ()
        local root = load(path)
        local gleissystem = assert(findChild(root, "Gleissystem"))
        local gleis = assert(findChild(gleissystem, "Gleis"))
        local dreibein = assert(findChild(gleis, "Dreibein"))
        local vektor = assert(findChild(dreibein, "Vektor"))
        assert.equals("Pos", vektor.text)
    end)

    it("finds deeply nested elements via findAll", function ()
        local root = load(path)
        local kontakte = findAll(root, "Kontakt")
        assert.equals(1, #kontakte)
        assert.equals("einfahrt", kontakte[1].attrs.LuaFn)
        local meldungen = findAll(root, "Meldung")
        assert.equals(1, #meldungen)
        assert.equals("Signal 1", meldungen[1].attrs.name)
        assert.equals("5", meldungen[1].attrs.Key_Id)
    end)

    it("skips XML declaration and preserves all real elements", function ()
        local root = load(path)
        -- If <?xml?> were added as a node, root.tag would not be "sutrackp"
        assert.equals("sutrackp", root.tag)
    end)

    it("parses the real smallest anl3 file and returns sutrackp root", function ()
        local realPath = "../Resourcen/Anlagen/ce/Control_Extension-Demo-Testen/Control_Extension-Lua-Testbeispiel.anl3"
        local root, err = Anl3ToTable.loadAnlage(realPath)
        assert.is_nil(err)
        assert.is_not_nil(root)
        if root then
            assert.equals("sutrackp", root.tag)
            local eepLua = assert(findChild(root, "EEPLua"))
            assert.equals("\\Control_Extension-Lua-Testbeispiel.lua", eepLua.attrs.LUAPath)
            assert.is_true(#findAll(root, "Kontakt") > 0)
            assert.is_true(#findAll(root, "Zugverband") > 0)
        end
    end)
end)
