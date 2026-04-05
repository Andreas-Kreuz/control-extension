---@meta

---@class StructureStaticDto
---@field id string
---@field name string
---@field pos_x number
---@field pos_y number
---@field pos_z number
---@field rot_x number
---@field rot_y number
---@field rot_z number
---@field modelType number
---@field modelTypeText string
---@field tag string

---@class StructureDynamicDto
---@field id string
---@field light boolean
---@field smoke boolean
---@field fire boolean

---@class StructureStaticDtoFactory
---@field createDto fun(structure: table):string,string,string|number,StructureStaticDto
---@field createDtoList fun(structures: table):string,string,table
---@field createRefDto fun(structureId: string):string,string,string|number,table

---@class StructureDynamicDtoFactory
---@field createDto fun(structure: table):string,string,string|number,StructureDynamicDto
---@field createDtoList fun(structures: table):string,string,table
---@field createRefDto fun(structureId: string):string,string,string|number,table
