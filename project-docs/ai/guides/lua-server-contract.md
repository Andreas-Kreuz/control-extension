# Lua ↔ Server Contract Guide

## Terminology

- `ceType` — domain contract term used in Lua and at the Lua↔Server boundary
- `room` — server-side subscription/transport term only, never used in Lua
- `keyId` — unique key within a ceType identifying a single DTO instance
- `*LuaDto` — TypeScript shape for Lua output in `apps/web-server/src/server/ce/dto/`
- `*AppDto` — stable Server↔Web App shape in `apps/web-shared/src/dtos/app/`

## DTO Sync Checklist

When changing an exported `ceType`, its `keyId`, or DTO fields, update in sync:

1. `*DtoTypes.d.lua` — Lua type definition
2. `*DtoTypes.d.md` — Lua DTO documentation
3. The responsible `*DtoFactory.lua` — Lua factory
4. Server `*LuaDto` type in `apps/web-server/src/server/ce/dto/` — must match Lua factory output
5. Affected server docs

## ceType Rename Checklist

On `ceType` name changes, also check:

- Server selectors and app-facing mapping comments in `apps/web-server/src/server/mod/`
- Static app API room mappings in `apps/web-server/src/server/eep/server-data/static/`
- Cypress fixtures in `apps/web-app/cypress/fixtures/`
- E2E assertions

Do not update non-generic Web App subscriptions for a Lua `ceType` rename. The Web App subscribes
to stable app API/room names from `apps/web-shared`; the server mapping absorbs Lua-side renames.

## DTO Documentation

- `lua/LUA/ce/hub/data/README.md` — hub DTO overview
- `DTO.md` and `*DtoTypes.d.md` files alongside factories

## Contract Direction

- Lua-side contract changes must be absorbed by the server (via selectors) before reaching the stable `*AppDto` client contract in `apps/web-shared`
- The server is the transformation layer — Lua stays close to raw EEP data
- Lua, server, and web app are always deployed together as one bundle — do not add server-side backwards-compat fallbacks for old Lua DTO formats
