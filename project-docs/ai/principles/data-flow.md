# CE Principle: Data Flow

Canonical flow:

`EEP -> Lua Hub DTOs -> optional CeModule DTOs -> Data Bridge -> Server selectors/store -> web-shared DTOs -> Web App view models`

Boundary contracts:

- `EEP -> Lua Hub`: raw EEP state, variables, getters, setters, callbacks
- `Lua Hub -> Data Bridge`: Lua DTOs from the hub; CeModules may publish additional module-specific DTOs separately
- `Data Bridge -> Server`: file-based transport of events from CE; transport stays schema-agnostic
- `Server -> Web App`: `apps/web-shared` DTOs and events as the stable client contract

Rules:

- Raw data stays raw in `Lua Hub`.
- Transforming or composing domain data belongs in optional `CeModule`s, not in hub DTO factories.
- `Data Bridge` must stay transparent and must not become a second business layer.
- Client-oriented reduction happens on the `Server`, not in Lua.
- The Web App depends only on the server contract in `apps/web-shared`, never on Lua DTO details.

Detail:

- [../data-flow/details.md](../data-flow/details.md)

Compact intent: keep the Lua side close to EEP, keep transport dumb, keep the client contract stable, and move consumer-specific shaping to the server.
