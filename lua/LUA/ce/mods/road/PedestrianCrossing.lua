if CeDebugLoad then print("[#Start] Loading ce.mods.road.PedestrianCrossing ...") end

---@class PedestrianCrossing
---@field type string
---@field name string
---@field approach LaneApproach
---@field heading LaneHeading Deprecated: opposite of approach
---@field _scriptVariableName string|nil
---@field Approach table<string, LaneApproach>
---@field Heading table<string, LaneHeading> Deprecated: use Approach
---@field getType fun(self: PedestrianCrossing):string
---@field getName fun(self: PedestrianCrossing):string
---@field getScriptVariableName fun(self: PedestrianCrossing):string|nil
---@field getApproach fun(self: PedestrianCrossing):LaneApproach
---@field getHeading fun(self: PedestrianCrossing):LaneHeading Deprecated: opposite of approach
---@field new fun(self: PedestrianCrossing, name: string):PedestrianCrossing
---@field scriptVariableName fun(self: PedestrianCrossing, scriptVariableName: string):PedestrianCrossing
---@field setScriptVariableName fun(self: PedestrianCrossing, scriptVariableName: string):PedestrianCrossing
---@field setApproach fun(self: PedestrianCrossing, approach: LaneApproach):PedestrianCrossing
---@field setHeading fun(self: PedestrianCrossing, heading: LaneHeading):PedestrianCrossing Deprecated: use setApproach

local Lane = require("ce.mods.road.Lane")

local PedestrianCrossing = {}
PedestrianCrossing.Approach = Lane.Approach
---@deprecated Use PedestrianCrossing.Approach and setApproach(...).
---@diagnostic disable-next-line: deprecated
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
        heading = Lane.headingFromApproach(PedestrianCrossing.Approach.SOUTH),
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
    ---@diagnostic disable-next-line: deprecated
    if not PedestrianCrossing.Heading[heading] then
        print(string.format("[#PedestrianCrossing] No such heading: %s", tostring(heading)))
    else
        self:setApproach(Lane.approachFromHeading(heading))
    end
    return self
end

return PedestrianCrossing
