if CeDebugLoad then print("[#Start] Loading ce.mods.road.PedestrianCrossing ...") end

local Lane = require("ce.mods.road.Lane")

local PedestrianCrossing = {}
PedestrianCrossing.Approach = Lane.Approach
---@deprecated Use PedestrianCrossing.Approach and setApproach(...).
PedestrianCrossing.Heading = Lane.Heading

function PedestrianCrossing.getType() return "PedestrianCrossing" end

function PedestrianCrossing:getName() return self.name end

function PedestrianCrossing:getScriptVariableName() return self._scriptVariableName end

function PedestrianCrossing:getApproach() return self.approach end

function PedestrianCrossing:getHeading() return self.heading end

function PedestrianCrossing:new(name)
    assert(type(name) == "string", "Need 'name' as string")
    local o = {
        name = name,
        type = "PedestrianCrossing",
        approach = PedestrianCrossing.Approach.SOUTH,
        heading = PedestrianCrossing.Heading.NORTH,
        _scriptVariableName = nil
    }
    self.__index = self
    setmetatable(o, self)
    o:setApproach(o.approach)
    return o
end

function PedestrianCrossing:setScriptVariableName(scriptVariableName)
    assert(type(scriptVariableName) == "string", "Need 'scriptVariableName' as string")
    self._scriptVariableName = scriptVariableName
    return self
end

function PedestrianCrossing:scriptVariableName(scriptVariableName)
    return self:setScriptVariableName(scriptVariableName)
end

function PedestrianCrossing:setApproach(approach)
    if not PedestrianCrossing.Approach[approach] then
        print(string.format("[#PedestrianCrossing] No such approach: %s", tostring(approach)))
    else
        self.approach = approach
        self.heading = Lane.headingFromApproach(approach)
    end
    return self
end

function PedestrianCrossing:setHeading(heading)
    if not PedestrianCrossing.Heading[heading] then
        print(string.format("[#PedestrianCrossing] No such heading: %s", tostring(heading)))
    else
        self:setApproach(Lane.approachFromHeading(heading))
    end
    return self
end

return PedestrianCrossing
