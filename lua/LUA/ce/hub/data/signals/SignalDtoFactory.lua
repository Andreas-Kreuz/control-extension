-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/signals/SignalLuaDto.ts, WaitingOnSignalLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SignalDtoFactory = {}

local SIGNAL_CE_TYPE = HubCeTypes.Signal
local WAITING_CE_TYPE = HubCeTypes.WaitingOnSignal
local KEY_ID = "id"

local function toSignalDto(signal)
    return {
        ceType = SIGNAL_CE_TYPE,
        id = signal.id,
        position = signal.position,
        tag = signal.tag,
        waitingVehiclesCount = signal.waitingVehiclesCount
    }
end

function SignalDtoFactory.createSignalDto(signal)
    local dto = toSignalDto(signal)
    return SIGNAL_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createSignalDtoList(signals)
    local signalDtos = {}
    for i = 1, #signals do
        local _, _, _, dto = SignalDtoFactory.createSignalDto(signals[i])
        signalDtos[i] = dto
    end
    return SIGNAL_CE_TYPE, KEY_ID, signalDtos
end

local function toWaitingOnSignalDto(waiting)
    return {
        ceType = WAITING_CE_TYPE,
        id = waiting.id,
        signalId = waiting.signalId,
        waitingPosition = waiting.waitingPosition,
        vehicleName = waiting.vehicleName,
        waitingCount = waiting.waitingCount
    }
end

function SignalDtoFactory.createWaitingOnSignalDto(waiting)
    local dto = toWaitingOnSignalDto(waiting)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createWaitingOnSignalDtoList(waitingOnSignals)
    local waitingOnSignalDtos = {}
    for i = 1, #waitingOnSignals do
        local _, _, _, dto = SignalDtoFactory.createWaitingOnSignalDto(waitingOnSignals[i])
        waitingOnSignalDtos[i] = dto
    end
    return WAITING_CE_TYPE, KEY_ID, waitingOnSignalDtos
end

return SignalDtoFactory
