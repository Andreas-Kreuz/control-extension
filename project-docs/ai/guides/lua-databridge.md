# DataBridge Guide

## Role

File-based transport between Lua Hub and external consumers. No schema knowledge — purely serializes and deserializes.

## Paths

- Code: `lua/LUA/ce/databridge/`
- Outgoing events: `ServerEventBuffer.lua` → writes `events-from-ce` (newline-delimited JSON)
- Incoming commands: `IncomingCommandFileReader.lua` → reads `commands-to-ce`
- Command execution: `IncomingCommandExecutor.lua` — only registered commands are executed

## Encoding

- Exchange files (`lua/LUA/ce/databridge/exchange/`) are Latin1
- See [../encoding/rules.md](../encoding/rules.md) for file encoding rules

## Command Registration

- Lua must register allowed commands before they can be executed
- Unregistered commands from `commands-to-ce` are silently ignored
- The `commands-to-ce` file is an open input channel — the server is only one possible writer

## Independence

- DataBridge works without the server — it only requires Lua Hub
- External tools or users can write `commands-to-ce` directly
