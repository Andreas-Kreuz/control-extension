# CE Component: Web App

Role:

- React-based user interface
- consumes server APIs and events
- derives local view models for rendering

Boundary:

- input: server APIs and Socket.IO events defined via `apps/web-shared`
- no direct Lua or Data Bridge access

Rules:

- depends on the server contract only
- view-specific reduction stays local to the app
- must not couple itself to Lua DTO details
