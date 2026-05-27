insulate("ce.mods.road.TrafficLightModel", function ()
    it("infers known traffic light models from EEP item names", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        assert.equals(TrafficLightModel.Unsichtbar_2er,
                      TrafficLightModel.inferFromItemName("Signale/Signale/Signal_unsichtbar.3dm"))
        assert.equals(TrafficLightModel.JS2_3er_mit_FG,
                      TrafficLightModel.inferFromItemName("Resourcen/Signale/3erAmpel_FG_JS2.3dm"))
        assert.equals(TrafficLightModel.JS2_3er_ohne_FG,
                      TrafficLightModel.inferFromItemName("Resourcen/Signale/3erAmpel_JS2.3dm"))
        assert.equals(TrafficLightModel.NP1_3er_mit_FG,
                      TrafficLightModel.inferFromItemName("Resourcen/Signale/Ampel_Einzel_FD_NP1.3dm"))
        assert.equals(TrafficLightModel.JS2_2er_nur_FG,
                      TrafficLightModel.inferFromItemName("Signale/Signale/3erFGwestMast_JS2.3dm"))
        assert.equals(TrafficLightModel.JS2_2er_rot_gelb_gruen_aus,
                      TrafficLightModel.inferFromItemName("Signale/Signale/2erRotGelbNormalMast_JS2.3dm"))
        assert.equals(TrafficLightModel.NP1_2er_nur_FG,
                      TrafficLightModel.inferFromItemName("Signale/Signale/Ampel_NurFussg_FD_NP1.3dm"))
        assert.equals(TrafficLightModel.MA1_STRAB_2er_2_gruen,
                      TrafficLightModel.inferFromItemName("Signale/Signale/StraBahnSignal_01_MA1.3dm"))
        assert.equals(TrafficLightModel.MA1_STRAB_3er_2_gruen,
                      TrafficLightModel.inferFromItemName("Signale/Signale/StraBahnSignal_05_MA1.3dm"))
        assert.equals(TrafficLightModel.MA1_STRAB_3er_2_gruen,
                      TrafficLightModel.inferFromItemName("Signale/Signale/StraBahnSignal_06_MA1.3dm"))
        assert.equals(TrafficLightModel.MA1_STRAB_3er_2_gruen,
                      TrafficLightModel.inferFromItemName("Signale/Signale/StraBahnSignal_07_MA1.3dm"))
        assert.equals(TrafficLightModel.DH1_blink_gelb,
                      TrafficLightModel.inferFromItemName("Signale/Signale/Ampel_gBl_DH1.3dm"))
        assert.equals(TrafficLightModel.DH1_3er,
                      TrafficLightModel.inferFromItemName("Signale/Signale/Ampel_1_gerade_DH1.3dm"))
    end)

    it("keeps old non-DH1 public constants", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local constants = {
            "JS2_3er_mit_FG",
            "JS2_3er_ohne_FG",
            "JS2_2er_nur_FG",
            "JS2_2er_gelb_gruen_aus",
            "JS2_2er_OFF_YELLOW_GREEN",
            "JS2_2er_rot_gelb_aus",
            "JS2_2er_rot_gruen",
            "JS2_1er_gruen",
            "NP1_3er_mit_FG",
            "NP1_3er_ohne_FG",
            "Unsichtbar_2er",
            "NONE"
        }

        for _, constant in ipairs(constants) do
            assert.is_not_nil(TrafficLightModel[constant], constant)
        end
        assert.equals(TrafficLightModel.JS2_2er_gelb_gruen_aus,
                      TrafficLightModel.JS2_2er_OFF_YELLOW_GREEN)
    end)

    it("keeps old non-DH1 public constant indexes unchanged", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local expectedByConstant = {
            MA1_STRAB_4er_2_gruen = {
                signalIndexRed = 1,
                signalIndexGreen = 2,
                signalIndexYellow = 4,
                signalIndexRedYellow = 4,
                signalIndexSwitchOff = 2,
                signalIndexGreenYellow = 2
            },
            MA1_STRAB_4er_3_gruen = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 4,
                signalIndexRedYellow = 4,
                signalIndexSwitchOff = 3,
                signalIndexGreenYellow = 3
            },
            MA1_STRAB_3er_2_gruen = {
                signalIndexRed = 1,
                signalIndexGreen = 2,
                signalIndexYellow = 3,
                signalIndexRedYellow = 3,
                signalIndexSwitchOff = 2,
                signalIndexGreenYellow = 2
            },
            NP1_3er_mit_FG = {
                signalIndexRed = 2,
                signalIndexGreen = 4,
                signalIndexYellow = 5,
                signalIndexRedYellow = 3,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 4,
                signalIndexGreenYellow = 4
            },
            NP1_3er_ohne_FG = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 4,
                signalIndexRedYellow = 2,
                signalIndexSwitchOff = 3,
                signalIndexGreenYellow = 3
            },
            JS2_2er_nur_FG = {
                signalIndexRed = 1,
                signalIndexGreen = 1,
                signalIndexYellow = 1,
                signalIndexRedYellow = 1,
                signalIndexPedestrian = 2,
                signalIndexSwitchOff = 3,
                signalIndexBlinkYellow = 3,
                signalIndexGreenYellow = 4
            },
            JS2_2er_gelb_gruen_aus = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 5,
                signalIndexRedYellow = 1,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 2,
                signalIndexBlinkYellow = 6,
                signalIndexGreenYellow = 4
            },
            JS2_2er_rot_gelb_aus = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 2,
                signalIndexRedYellow = 4,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 3,
                signalIndexBlinkYellow = 5,
                signalIndexGreenYellow = 3
            },
            JS2_2er_rot_gruen = {
                signalIndexRed = 1,
                signalIndexGreen = 2,
                signalIndexYellow = 1,
                signalIndexRedYellow = 1,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 3,
                signalIndexBlinkYellow = 3,
                signalIndexGreenYellow = 2
            },
            JS2_1er_gruen = {
                signalIndexRed = 1,
                signalIndexGreen = 2,
                signalIndexYellow = 1,
                signalIndexRedYellow = 1,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 1,
                signalIndexBlinkYellow = 1,
                signalIndexGreenYellow = 2
            },
            JS2_3er_mit_FG = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 5,
                signalIndexRedYellow = 2,
                signalIndexPedestrian = 6,
                signalIndexSwitchOff = 7,
                signalIndexBlinkYellow = 8,
                signalIndexGreenYellow = 4
            },
            JS2_3er_ohne_FG = {
                signalIndexRed = 1,
                signalIndexGreen = 3,
                signalIndexYellow = 5,
                signalIndexRedYellow = 2,
                signalIndexPedestrian = 1,
                signalIndexSwitchOff = 6,
                signalIndexBlinkYellow = 7,
                signalIndexGreenYellow = 4
            },
            Unsichtbar_2er = {
                signalIndexRed = 2,
                signalIndexGreen = 1,
                signalIndexYellow = 2,
                signalIndexRedYellow = 2,
                signalIndexPedestrian = 2,
                signalIndexSwitchOff = 1,
                signalIndexBlinkYellow = 1,
                signalIndexGreenYellow = 1
            },
            NONE = {
                signalIndexRed = 1,
                signalIndexGreen = 2,
                signalIndexYellow = 3,
                signalIndexRedYellow = 4,
                signalIndexPedestrian = 5,
                signalIndexSwitchOff = 6,
                signalIndexBlinkYellow = 7,
                signalIndexGreenYellow = 2
            }
        }
        local fields = {
            "signalIndexRed",
            "signalIndexGreen",
            "signalIndexYellow",
            "signalIndexRedYellow",
            "signalIndexPedestrian",
            "signalIndexSwitchOff",
            "signalIndexBlinkYellow",
            "signalIndexGreenYellow"
        }

        for constant, expected in pairs(expectedByConstant) do
            local model = TrafficLightModel[constant]
            for _, field in ipairs(fields) do
                assert.equals(expected[field], model[field], constant .. "." .. field)
            end
        end
    end)

    it("uses unique model ids", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local seen = {}
        for _, model in ipairs(TrafficLightModel.getAllOrdered()) do
            assert.is_nil(seen[model.id], "duplicate model id: " .. model.id)
            seen[model.id] = true
        end
    end)

    local function basename(value)
        return string.match(value:gsub("\\", "/"), "([^/]+)$") or value
    end

    local function normalizedModelName(value)
        return string.lower(string.gsub(basename(value), "%.[^.]+$", ""))
    end

    local function matchesAnyPattern(TrafficLightModel, name)
        local normalized = normalizedModelName(name)
        for _, model in ipairs(TrafficLightModel.getAllOrdered()) do
            for _, pattern in ipairs(model.modelNamePatterns or {}) do
                if string.match(normalized, pattern) then return true end
            end
        end
        return false
    end

    local ampelIniModels = {
        ["Ampel_gBl_DH1.ini"] = 'Name_GER = "Ampel gelb blinkend"',
        ["Ampel_1_gerade_DH1.ini"] = 'Name_GER = "Ampel gerade"',
        ["Ampel2_Zus_rechts_DH1.ini"] = 'Name_GER = "Zusatz-Ampel rechts"',
        ["Ampel_Einzel_FD_NP1.ini"] = 'Name_GER = "Ampel einzeln mit Fussgaenger"',
        ["Ampel_2Spur_Mitte_NP1.ini"] = 'Description_GER = "Ampel zweispurig"',
        ["Ampel_NurFussg_FD_NP1.ini"] = 'Name_GER = "Fussgaenger-Ampel"',
        ["Baustellenampel_NP1.ini"] = 'Name_GER = "Baustellenampel"',
        ["1erLinksMast_JS2.ini"] = 'Name_GER = "1er Ampel"',
        ["2erFGwestMast_JS2.ini"] = 'Name_GER = "Fussgaenger-Ampel"',
        ["2erGruenGelbLMitte_JS2.ini"] = 'Name_GER = "Ampel gelb/gruen"',
        ["2erRotGelbMast_JS2.ini"] = 'Name_GER = "Ampel rot/gelb"',
        ["2erRotGelbNormalMast_JS2.ini"] = 'Name_GER = "Ampel rot/gelb/gruen"',
        ["2erRotGruenMast_JS2.ini"] = 'Name_GER = "Ampel rot/gruen"',
        ["3erAmpel_FG_JS2.ini"] = 'Name_GER = "Ampel mit Fussgaenger"',
        ["3erAmpel_JS2.ini"] = 'Name_GER = "Ampel ohne Fussgaenger"',
        ["Andreaskreuz_DH1.ini"] = 'Name_GER = "Bahnuebergang"'
    }

    local ma1IniModels = {
        ["StraBahnSignal_01_MA1.ini"] = table.concat({
                                                          'Pos1_Fn_Name_GER = "Halt"',
                                                          'Pos2_Fn_Name_GER = "Fahrt geradeaus"'
                                                      }, "\n"),
        ["StraBahnSignal_05_MA1.ini"] = table.concat({
                                                          'Pos1_Fn_Name_GER = "Halt"',
                                                          'Pos2_Fn_Name_GER = "Fahrt geradeaus"',
                                                          'Pos3_Fn_Name_GER = "Halt erwarten"'
                                                      }, "\n"),
        ["StraBahnSignal_06_MA1.ini"] = table.concat({
                                                          'Pos1_Fn_Name_GER = "Halt"',
                                                          'Pos2_Fn_Name_GER = "Fahrt rechts"',
                                                          'Pos3_Fn_Name_GER = "Halt erwarten"'
                                                      }, "\n"),
        ["StraBahnSignal_07_MA1.ini"] = table.concat({
                                                          'Pos1_Fn_Name_GER = "Halt"',
                                                          'Pos2_Fn_Name_GER = "Fahrt links"',
                                                          'Pos3_Fn_Name_GER = "Halt erwarten"'
                                                      }, "\n"),
        ["StrabaSigGM_4_MA1.ini"] = table.concat({
                                                      'Pos1_Fn_Name_GER = "Halt"',
                                                      'Pos2_Fn_Name_GER = "Vorfahrt beachten"',
                                                      'Pos3_Fn_Name_GER = "Halt erwarten"'
                                                  }, "\n")
    }

    it("detects every JS2, NP1 and DH1 Ampel ini model", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local checked = 0
        for fileName, content in pairs(ampelIniModels) do
            local hasSupportedSuffix = string.match(fileName, "_DH1%.ini$") or
                string.match(fileName, "_NP1%.ini$") or string.match(fileName, "_JS2%.ini$")
            if hasSupportedSuffix then
                local isAmpel = string.match(fileName, "[Aa]mpel") or
                    string.match(content, "Name_GER%s*=%s*\"[^\"]*[Aa]mpel") or
                    string.match(content, "Description_GER%s*=%s*\"[^\"]*[Aa]mpel")
                if isAmpel then
                    assert.is_true(matchesAnyPattern(TrafficLightModel, fileName), fileName)
                    assert.is_not_nil(TrafficLightModel.inferFromItemName(fileName), fileName)
                    checked = checked + 1
                end
            end
        end

        assert.is_true(checked > 0)
    end)

    it("detects requested MA1 tram signal ini models", function ()
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local checked = 0
        for fileName, content in pairs(ma1IniModels) do
            local positions = {}
            for index, label in string.gmatch(content, "Pos(%d+)_Fn_Name_GER%s*=%s*\"([^\"]*)\"") do
                positions[tonumber(index)] = label
            end
            local model = TrafficLightModel.inferFromItemName(fileName)
            local isTwoPositionDirection = #positions == 2 and positions[1] == "Halt" and
                string.match(positions[2] or "", "^Fahrt ")
            local isThreePositionDirection = #positions == 3 and positions[1] == "Halt" and
                positions[3] == "Halt erwarten" and string.match(positions[2] or "", "^Fahrt ") and
                not string.find(positions[2] or "", "Vorfahrt", 1, true)

            if isTwoPositionDirection then
                checked = checked + 1
                assert.equals(2, model.signalIndexGreen, fileName)
                assert.equals(1, model.signalIndexYellow, fileName)
            elseif isThreePositionDirection then
                checked = checked + 1
                assert.equals(2, model.signalIndexGreen, fileName)
                assert.equals(3, model.signalIndexYellow, fileName)
            else
                assert.is_nil(model, fileName)
            end
        end

        assert.equals(4, checked)
    end)
end)
