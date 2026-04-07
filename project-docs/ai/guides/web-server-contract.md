# Web Server & Contract Guide

## Stack

- Web Server: Electron / Node in TypeScript (`apps/web-server`)
- Shared types and events: `apps/web-shared`

## Terminology Boundary

- `room` — subscription/transport term on the server side
- `ceType` — Lua-side domain term, not used in client-facing code

## Server-Generated Data

- `ce.server.ApiEntries` and `ce.server.ServerStats` are derived server-side from current data, not from Lua
- Details: `apps/web-server/src/server/eep/server-data/README.md`

## Contract Rules

- API changes must keep `apps/web-shared` types and events consistent
- Lua-side contract changes should be absorbed by the server before reaching the stable client contract
- The server must remain usable without the web app

## Commands

- Headless server: `yarn workspace @ce/web-server run run:headless`

## Testing

- After contract changes, verify `@ce/web-shared` and affected web-app consumers
