# CE Component: Server

Role:

- receive Lua-side data from the Data Bridge
- maintain an independent server-side store
- provide REST and Socket.IO interfaces
- tailor data for consumers through selectors

Boundary:

- input: file-based events from the Data Bridge
- output: `apps/web-shared` DTOs and events

Rules:

- client-oriented reduction happens here, not in Lua
- the server must remain usable without the web app
- Lua-side contract changes should be absorbed before they reach the stable client contract
