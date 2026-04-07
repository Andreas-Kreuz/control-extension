# CE Principle: Command Flow

Reverse flow:

`Web App / users / external tools -> Server optional -> commands-to-ce -> Data Bridge -> registered Lua command -> EEP main cycle`

Rules:

- `commands-to-ce`-file is an open input channel
- the server is only one possible writer
- Lua must register allowed commands first
- unregistered commands are ignored

Rule: commands are open at the file boundary, restricted at Lua execution.
