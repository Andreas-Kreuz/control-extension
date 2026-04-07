---@meta

---@class SwitchRegistry
---@field has fun(switchId: number):boolean
---@field add fun(switch: Switch):nil
---@field get fun(switchId: number):Switch|nil
---@field getAll fun():table<number, Switch>

---@class SwitchDiscovery
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil

---@class SwitchUpdater
---@field runUpdate fun():nil

---@class SwitchPublisher
---@field syncState fun():table

---@class SwitchStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():table
