---@meta

---@class SignalStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():table

---@class SignalRegistry
---@field has fun(signalId: number):boolean
---@field add fun(signal: Signal):nil
---@field get fun(signalId: number):Signal|nil
---@field getAll fun():table<number, Signal>

---@class SignalDiscovery
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil

---@class SignalUpdater
---@field runUpdate fun(options: table|nil):nil

---@class SignalPublisher
---@field syncState fun(options: table|nil):table
