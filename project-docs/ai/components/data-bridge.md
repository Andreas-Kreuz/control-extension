# CE Component: Data Bridge

Role:

- file-based transport between Lua and external consumers
- forwards outgoing events and accepts incoming commands

Boundary:

- output channel: event files such as `events-from-ce`
- input channel: command files such as `commands-to-ce`

Rules:

- transport only; no schema knowledge or business transformation
- must stay usable without the server
- command execution stays restricted by Lua-side registration
