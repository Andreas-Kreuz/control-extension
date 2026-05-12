# DataBridge Guide

## Role

Transport between Lua Hub and external consumers. No schema knowledge — purely serializes and deserializes.

## Paths

- Code: `lua/LUA/ce/databridge/`
- Outgoing events: `ServerEventBuffer.lua` buffers newline-delimited JSON and sends it through the selected event transport
- Default event transport: named pipe, selected by `ControlExtension.setTransport("pipe")`
- Fallback/legacy event transport: file, selected by `ControlExtension.setTransport("file")`, writes `events-from-ce` plus `events-from-ce.pending`
- Incoming commands: `IncomingCommandFileReader.lua` → reads `commands-to-ce`
- Command execution: `IncomingCommandExecutor.lua` — only registered commands are executed
- Pipe discovery: the server writes runtime-only `server-transport.json` in the exchange directory; Lua reads it to find the pipe and detect server sessions

## Encoding

- Exchange files (`lua/LUA/ce/databridge/exchange/`) are Latin1
- See [../encoding/rules.md](../encoding/rules.md) for file encoding rules

## Pipe Transport

- Pipe transport is Lua-to-server events only; commands stay file-based through `commands-to-ce`
- Lua writes only when `server-is-running` and `server-transport.json` both exist
- `server-transport.json` contains `eventTransport`, `pipeName`, and `sessionId`
- `pipeName` is a random Windows named pipe path created by the server for the current run
- `sessionId` changes when the server starts a new pipe session; Lua treats this as a server restart and requests a full resync
- The descriptor is runtime state, not source data, and must not be committed
- Random pipe names avoid collisions and accidental writes, but are not a security boundary

## Command Registration

- Lua must register allowed commands before they can be executed
- Unregistered commands from `commands-to-ce` are silently ignored
- The `commands-to-ce` file is an open input channel — the server is only one possible writer

## Independence

- DataBridge works without the server — it only requires Lua Hub
- External tools or users can write `commands-to-ce` directly
