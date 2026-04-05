# DTO Layer Architecture

This directory contains **LuaDto** interfaces — the raw data contracts between EEP's Lua scripting
engine and this server.

## Three-tier data flow

```text
Lua DtoFactory  <--comment cross-reference-->  *LuaDto (this directory)
      |
      | events-from-ce (newline-delimited JSON, latin1)
      v
*LuaDto   [web-server/src/server/ce/dto/]     server-internal only
      |
      | Selector.ts (transformation / stability layer)
      v
*Dto      [web-shared/src/dtos/server/]        stable client contract
      |
      | socket.io JSON
      v
Web-App receives *Dto
      |
      | React store (only if extra transformation is needed)
      v
View models  [web-app/src/.../model/]          UI-specific
```

## Rules

- **LuaDtos are server-internal only.** They must never be emitted directly to clients.
- **Selectors are the only bridge** between LuaDto and the client-facing `*Dto` in `web-shared`.
  They provide the stability layer: if Lua changes its output format, only the selector changes —
  client contracts in `web-shared/src/dtos/server/` remain stable.
- **Each LuaDto file** contains a comment pointing to the corresponding Lua DtoFactory source.
- **Each Lua DtoFactory** contains a comment pointing back to its TypeScript LuaDto counterpart.

## Cross-reference comment convention

In TypeScript:

```typescript
// Lua DtoFactory: lua/LUA/ce/hub/data/trains/TrainStaticDtoFactory.lua
export interface TrainStaticLuaDto { ... }
```

In Lua:

```lua
-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainStaticLuaDto.ts
local TrainStaticDtoFactory = {}
```

## Directory structure

```text
ce/dto/
  trains/           TrainStaticLuaDto    <- lua/LUA/ce/hub/data/trains/TrainStaticDtoFactory.lua
                    TrainDynamicLuaDto   <- lua/LUA/ce/hub/data/trains/TrainDynamicDtoFactory.lua
  rolling-stocks/   RollingStockStaticLuaDto  <- lua/LUA/ce/hub/data/rollingstock/RollingStockStaticDtoFactory.lua
                    RollingStockDynamicLuaDto <- lua/LUA/ce/hub/data/rollingstock/RollingStockDynamicDtoFactory.lua
  modules/          ModuleLuaDto         <- lua/LUA/ce/hub/data/modules/ModuleDtoFactory.lua
  runtime/          RuntimeLuaDto        <- lua/LUA/ce/hub/data/runtime/RuntimeDtoFactory.lua
  signals/          SignalLuaDto         <- lua/LUA/ce/hub/data/signals/SignalDtoFactory.lua
                    WaitingOnSignalLuaDto
  data-slots/       DataSlotLuaDto       <- lua/LUA/ce/hub/data/slots/DataSlotDtoFactory.lua
  structures/       StructureLuaDto      <- legacy combined structure DTO shape
                    StructureStaticLuaDto <- lua/LUA/ce/hub/data/structures/StructureStaticDtoFactory.lua
                    StructureDynamicLuaDto <- lua/LUA/ce/hub/data/structures/StructureDynamicDtoFactory.lua
  switches/         SwitchLuaDto         <- lua/LUA/ce/hub/data/switches/SwitchDtoFactory.lua
  time/             TimeLuaDto           <- lua/LUA/ce/hub/data/time/TimeDtoFactory.lua
  tracks/           TrackLuaDto          <- lua/LUA/ce/hub/data/tracks/TrackDtoFactory.lua
  version/          VersionLuaDto        <- lua/LUA/ce/hub/data/version/VersionDtoFactory.lua
  traffic-light-models/ TrafficLightModelLuaDto  <- lua/LUA/ce/mods/road/data/TrafficLightModelDtoFactory.lua
  roads/            IntersectionLuaDto           <- lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
                    IntersectionLaneLuaDto
                    IntersectionSwitchingLuaDto
                    IntersectionTrafficLightLuaDto
  transit/          TransitStationLuaDto         <- lua/LUA/ce/mods/transit/data/TransitDtoFactory.lua
                    TransitLineLuaDto
                    TransitLineSegmentLuaDto
  settings/         SettingLuaDto        <- used by road + transit module settings rooms
```
