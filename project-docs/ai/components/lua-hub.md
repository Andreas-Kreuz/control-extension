# CE Component: Lua Hub

Role:

- capture raw EEP state in Lua
- create hub DTOs from unchanged EEP data
- provide registration points for commands and module integration

Boundary:

- input: EEP API
- output: Lua DTOs for downstream consumers

Rules:

- hub DTO factories expose raw EEP data only
- no client-specific tailoring in the Lua Hub
- domain-specific transformation belongs in separate CeModules
