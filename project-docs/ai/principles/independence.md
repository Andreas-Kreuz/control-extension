# CE Principle: Independence

Each layer is usable on its own at its consumer boundary. Higher layers are optional.

1. `Lua Hub`: Lua-side runtime/orchestration root, usable without server or web app
2. `Data Bridge`: orchestrated by Lua Hub, still useful without server or web app
3. `Server`: needs Data Bridge, still useful without web app
4. `Web App`: needs server, has no direct Lua access

Rule: higher layers remain optional; Data Bridge remains transport-only.
