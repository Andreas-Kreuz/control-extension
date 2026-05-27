-- Lade das Hauptskript
require("ce.demo-anlagen.road-mod.Kreuzung1_mit_DH1_Ampeln-main")

-- Schalte Tipp-Texte ein
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
IntersectionSettings.showNameAndPhaseOnSignal = true

[EEPLuaData]
DS_2 = "scriptVariableName=c1,"
DS_100 = "f=2,p=Rot,q=#Opal Vitaro MEDIA MARKT|#Opal Vitaro MEDIA MARKT;001,w=0,"
DS_102 = "f=0,p=Rot,q=,w=1,"
DS_104 = "f=0,p=Rot,q=,w=1,"
DS_105 = "f=0,p=Rot,q=,w=2,"
DS_107 = "f=0,p=Rot,q=,w=1,"
DS_108 = "f=0,p=Rot,q=#B_GT6N-ER_B-Teil,w=1,"
