if CeDebugLoad then print("[#Start] Loading ce.hub.FullSyncMarker ...") end

local FullSyncMarker = {}

local function requireIfAvailable(moduleName)
    local ok, module = pcall(require, moduleName)
    if ok then return module end
    return nil
end

local function markEntry(entry)
    if entry then entry.needsFullSend = true end
end

local function markEntries(entries)
    for _, entry in pairs(entries or {}) do markEntry(entry) end
end

function FullSyncMarker.requestFullSync()
    local ModulesRegistry = requireIfAvailable("ce.hub.data.modules.ModulesRegistry")
    if ModulesRegistry and ModulesRegistry.get then markEntries(ModulesRegistry.get()) end

    local VersionRegistry = requireIfAvailable("ce.hub.data.version.VersionRegistry")
    if VersionRegistry and VersionRegistry.get then markEntry(VersionRegistry.get()) end

    local RuntimeRegistry = requireIfAvailable("ce.hub.data.runtime.RuntimeRegistry")
    if RuntimeRegistry and RuntimeRegistry.getAll then markEntries(RuntimeRegistry.getAll()) end

    local FrameDataRegistry = requireIfAvailable("ce.hub.data.framedata.FrameDataRegistry")
    if FrameDataRegistry and FrameDataRegistry.get then markEntry(FrameDataRegistry.get()) end

    local DataSlotsRegistry = requireIfAvailable("ce.hub.data.slots.DataSlotsRegistry")
    if DataSlotsRegistry then
        if DataSlotsRegistry.getFilled then markEntries(DataSlotsRegistry.getFilled()) end
        if DataSlotsRegistry.getEmpty then markEntries(DataSlotsRegistry.getEmpty()) end
    end

    local SignalRegistry = requireIfAvailable("ce.hub.data.signals.SignalRegistry")
    if SignalRegistry and SignalRegistry.getAll then markEntries(SignalRegistry.getAll()) end

    local WaitingOnSignalRegistry = requireIfAvailable("ce.hub.data.signals.WaitingOnSignalRegistry")
    if WaitingOnSignalRegistry and WaitingOnSignalRegistry.getAll then markEntries(WaitingOnSignalRegistry.getAll()) end

    local SwitchRegistry = requireIfAvailable("ce.hub.data.switches.SwitchRegistry")
    if SwitchRegistry and SwitchRegistry.getAll then markEntries(SwitchRegistry.getAll()) end

    local StructureRegistry = requireIfAvailable("ce.hub.data.structures.StructureRegistry")
    if StructureRegistry and StructureRegistry.getAll then markEntries(StructureRegistry.getAll()) end

    local ScenarioRegistry = requireIfAvailable("ce.hub.data.scenario.ScenarioRegistry")
    if ScenarioRegistry and ScenarioRegistry.get then markEntry(ScenarioRegistry.get()) end

    local TimeRegistry = requireIfAvailable("ce.hub.data.time.TimeRegistry")
    if TimeRegistry and TimeRegistry.get then markEntry(TimeRegistry.get()) end

    local RouteRegistry = requireIfAvailable("ce.hub.data.routes.RouteRegistry")
    if RouteRegistry and RouteRegistry.markDirty then RouteRegistry.markDirty() end

    local WeatherRegistry = requireIfAvailable("ce.hub.data.weather.WeatherRegistry")
    if WeatherRegistry and WeatherRegistry.get then markEntry(WeatherRegistry.get()) end

    local TrackRegistry = requireIfAvailable("ce.hub.data.tracks.TrackRegistry")
    if TrackRegistry then
        for _, trackType in ipairs({ "auxiliary", "control", "road", "rail", "tram" }) do
            if TrackRegistry.getAll then markEntries(TrackRegistry.getAll(trackType)) end
            if TrackRegistry.markInitialListPending then TrackRegistry.markInitialListPending(trackType) end
        end
    end

    local TrainRegistry = requireIfAvailable("ce.hub.data.trains.TrainRegistry")
    if TrainRegistry and TrainRegistry.getAll then markEntries(TrainRegistry.getAll()) end

    local RollingStockRegistry = requireIfAvailable("ce.hub.data.rollingstock.RollingStockRegistry")
    if RollingStockRegistry and RollingStockRegistry.getAll then markEntries(RollingStockRegistry.getAll()) end

    local ContactRegistry = requireIfAvailable("ce.hub.data.contacts.ContactRegistry")
    if ContactRegistry and ContactRegistry.getAll then markEntries(ContactRegistry.getAll()) end
end

return FullSyncMarker
