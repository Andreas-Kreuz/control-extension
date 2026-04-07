# Control Extension Components

Runtime stack:

1. [`EEP`](eep.md): host program and source of raw EEP state
2. [`lua/LUA/ce/hub`](lua-hub.md): Lua Hub, raw DTO creation, module integration
3. [`CeModule`](ce-module.md): optional Lua-side domain transformation layer
4. [`lua/LUA/ce/databridge`](data-bridge.md): file-based transport between Lua and external consumers
5. [`apps/web-server`](server.md): Node/Electron server, API, Socket.IO, selector layer
6. [`apps/web-shared`](web-shared.md): DTOs and events shared by server and web app
7. [`apps/web-app`](web-app.md): React UI, consumer of server API/events

Component references:

- [eep.md](eep.md)
- [lua-hub.md](lua-hub.md)
- [ce-module.md](ce-module.md)
- [data-bridge.md](data-bridge.md)
- [server.md](server.md)
- [web-shared.md](web-shared.md)
- [web-app.md](web-app.md)

Support code:

- `lua/LUA/spec`: Lua tests
- `pages/docs`: published project documentation
