# Project Overview

Control Extension is a Lua runtime extension for EEP (Eisenbahn.exe Professional), a railway simulation. It is a Yarn 4 monorepo with four optional, stackable layers:

```
EEP Program (Lua 5.3)
    └─> [1] Lua Hub          lua/LUA/ce/hub/
    └─> [2] Data Bridge      lua/LUA/ce/databridge/     (file I/O transport)
    └─> [3] Server           apps/web-server/           (Express + Electron)
    └─> [4] Web App          apps/web-app/              (React 19 + MUI)
                             apps/web-shared/           (shared TS types/events)
```

Each layer is independently usable — higher layers are optional.

## Monorepo Structure

- `lua/` — Lua codebase (Hub, DataBridge, CeModules)
- `apps/web-server/` — Electron / Node server
- `apps/web-app/` — React frontend
- `apps/web-shared/` — shared TypeScript types and events
- `pages/docs/` — published project documentation (Jekyll)
- `scripts/` — build, test, and utility scripts
- `project-docs/` — architecture and design documentation
