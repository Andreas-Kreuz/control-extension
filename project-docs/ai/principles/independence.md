# CE Principle: Independence

Each layer is usable on its own. Higher layers are optional.

1. `Lua Hub`: standalone for pure Lua/EEP logic
2. `Data Bridge`: needs Lua Hub, still useful without server or web app
3. `Server`: needs Data Bridge, still useful without web app
4. `Web App`: needs server, has no direct Lua access

Rule: depend upward, not downward.
