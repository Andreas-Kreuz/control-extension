# Web Server & Contract Guide

## Stack

- Web Server: Electron / Node in TypeScript (`apps/web-server`)
- Shared types and events: `apps/web-shared`

## Terminology Boundary

- `room` — subscription/transport term on the server side
- `ceType` — Lua-side domain term, not used in client-facing code
- `*LuaDto` — Lua↔Server boundary DTO shape under `apps/web-server/src/server/ce/dto/`
- `*AppDto` — Server↔Web App DTO shape under `apps/web-shared/src/dtos/app/`
- `DomainRoom` — stable Server↔Web App transport for `*AppDto` feature data
- `CeTypeRoom` — dynamic raw `ceType` transport for the generic data explorer only

## Server-Generated Data

- `server.api-entries` is derived server-side from raw `ceType` data for the generic explorer
- server stats are sent through `ServerStatsRoom`, not through raw API-data aliases
- Details: `apps/web-server/src/server/eep/server-data/README.md`

## Contract Rules

- API changes must keep `apps/web-shared` types and events consistent
- Lua-side contract changes should be absorbed by the server before reaching the stable client contract
- The server must remain usable without the web app
- App-facing DTOs must use the `XxxAppDto` naming convention; do not introduce new shared `XxxDto` types.
- Non-generic Web App code must not import or subscribe via `CeTypes`.
- Non-generic Web App code must use stable `DomainRoom`s for AppDto transfers.
- `DomainRoomRegistry` should stay minimal and must not mirror Lua `CeTypes` through alternate API-name constants.
- The generic raw data explorer may use raw `ceType` names via `useApiEntries`, `useTypeEntries`, `/data/:ceType`, and `CeTypeRoom`.
- Server mapping code should comment the corresponding Lua `ceType` next to app-facing room mappings.

## Commands

- Headless server: `yarn workspace @ce/web-server run run:headless`

## Testing

- After contract changes, verify `@ce/web-shared` and affected web-app consumers
