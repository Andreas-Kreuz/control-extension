---@meta

---@class StructureStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():table

---@class StructureRegistry
---@field has fun(structureId: string):boolean
---@field add fun(structure: Structure):nil
---@field remove fun(structureId: string):nil
---@field forId fun(structureId: string):Structure|nil
---@field getAll fun():table<string, Structure>

---@class StructureDiscovery
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil

---@class StructureUpdater
---@field runInitialUpdate fun(options: table|nil):nil
---@field runUpdate fun(options: table|nil):nil

---@class StructurePublisher
---@field syncState fun(options: table|nil):table

---@class StructureDataCollector
---@field collectInitialStructures fun():table
---@field refreshDirtyStructures fun(existingStructures: table):table
