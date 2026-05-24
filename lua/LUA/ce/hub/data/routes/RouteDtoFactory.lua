-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/routes/RouteLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.RouteDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class RouteDtoFactory
---@field createFullDto fun(route: Route):string,string,number,RouteDto
---@field createRouteDtoList fun(routes: table):string,string,table
local RouteDtoFactory = {}

local CE_TYPE = HubCeTypes.Route
local KEY_ID = "id"

-- DtoFields: class definition in RouteDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
}

local function buildFullDto(route)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = route.id
                                   }, route, dtoFields)
end

function RouteDtoFactory.createFullDto(route)
    local dto = buildFullDto(route)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RouteDtoFactory.createRouteDtoList(routes)
    local dtos = {}
    for _, route in pairs(routes) do
        local _, _, _, dto = RouteDtoFactory.createFullDto(route)
        dtos[#dtos + 1] = dto
    end
    table.sort(dtos, function (left, right) return left.id < right.id end)
    return CE_TYPE, KEY_ID, dtos
end

return RouteDtoFactory
