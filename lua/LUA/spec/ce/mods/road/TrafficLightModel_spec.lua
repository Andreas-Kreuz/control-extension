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
                      TrafficLightModel.inferFromItemName("Resourcen/Signale/Ampel FD_NP1.3dm"))
    end)
end)
