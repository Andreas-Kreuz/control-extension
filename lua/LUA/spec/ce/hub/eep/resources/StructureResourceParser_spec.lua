insulate("ce.hub.eep.resources.StructureResourceParser", function ()
    local Parser = require("ce.hub.eep.resources.StructureResourceParser")

    it("extracts localized model names", function ()
        local info = Parser.parseContent(table.concat({
                                                          "[FileInfo]",
                                                          'Name_ENG = "Tram Signal casing Mast 4"',
                                                          'Name_GER = "Straba Signal Geh\228use Mast 4"'
                                                      }, "\n"))

        assert.equals("Tram Signal casing Mast 4", info.modelNamesByLanguage.ENG)
        assert.equals("Straba Signal Geh\228use Mast 4", info.modelNamesByLanguage.GER)
        assert.equals("Straba Signal Geh\228use Mast 4", Parser.modelNameForLanguage(info, "GER"))
        assert.equals("Straba Signal Geh\228use Mast 4", Parser.modelNameForLanguage(info, "POL"))
    end)

    it("resolves structure ini paths below resources", function ()
        local primaryPath, fallbackPath =
            Parser.iniPathForGsbname("\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")

        assert.equals("Resourcen\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.ini", primaryPath)
        assert.equals("Resourcen.unp\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.ini", fallbackPath)
    end)

    it("uses the first existing ini path", function ()
        local fallbackPath = "StructureResourceParser_spec_fallback.ini"
        local file = assert(io.open(fallbackPath, "w"))
        file:write('Name_GER = "Ampelmast"\n')
        file:close()

        local info = Parser.parseFirstExistingFile({
            "not-existing/StructureResourceParser_spec.ini",
            fallbackPath
        })

        os.remove(fallbackPath)

        assert.equals("Ampelmast", info.modelNamesByLanguage.GER)
    end)
end)
