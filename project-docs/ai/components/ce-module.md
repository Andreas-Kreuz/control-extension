# CE Component: CeModule

Role:

- optional Lua-side extension point for domain logic
- transform, filter, or compose hub data into module-specific DTOs

Boundary:

- reads hub data and other Lua state
- publishes separate module-specific DTOs without changing hub contracts

Rules:

- optional by design; the system must work without a specific module
- must not redefine the Lua Hub as a client-tailoring layer
- should keep module concerns local instead of leaking them into shared hub DTOs
