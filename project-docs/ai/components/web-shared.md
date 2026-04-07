# CE Component: web-shared

Role:

- shared TypeScript DTO and event contract between server and web app

Boundary:

- consumed by the server as the published client contract
- consumed by the web app as the only shared data model it depends on

Rule:

- keep the client contract stable and shared in one place
