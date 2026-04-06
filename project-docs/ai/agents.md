# Control Extension AI Reference

Be concise with your answers. Do not acknowledge my messages causing duplication unless explicitly asked to do so. Do not provide summaries of the changes you made unless explicitly asked to do so.
Only perform the tasks that have been asked by the user to perform. You are not permitted to modify files and code that are not relevant to the problem specified by the user. Your job is to do what you're told to do. Only express creativity when explicitly asked to do so.
Start here. Follow links downward only for the domain you need.

Project:

- [overview.md](overview.md): what this project is — stack, layers, monorepo structure
- [guides/commands.md](guides/commands.md): yarn commands — build, test, lint, format, dev

Lua guides:

- [guides/lua-runtime.md](guides/lua-runtime.md): pure Lua/EEP — runtime, EepOriginalApi, state, error handling, commands, testing
- [guides/lua-databridge.md](guides/lua-databridge.md): file-based transport — event/command exchange, encoding, command registration
- [guides/lua-server-contract.md](guides/lua-server-contract.md): DTO sync — ceType/keyId changes, rename checklist, contract direction

Web guides:

- [guides/web-app.md](guides/web-app.md): React UI — stack, Cypress conventions, commands, testing
- [guides/web-server-contract.md](guides/web-server-contract.md): server APIs and web-shared contract — server-generated data, Lua absorption, stability rules

Documentation guides:

- [guides/docs-ai.md](guides/docs-ai.md): maintaining this AI doc tree — tree rules, when to update
- [guides/docs-project.md](guides/docs-project.md): project docs, READMEs, README_DEVs, published pages

Architecture:

- [components/overview.md](components/overview.md): runtime stack and component contracts
- [principles/data-flow.md](principles/data-flow.md): canonical data flow
- [principles/command-flow.md](principles/command-flow.md): reverse command flow
- [principles/independence.md](principles/independence.md): layer independence

Cross-cutting:

- [encoding/rules.md](encoding/rules.md): file encoding (Latin1 vs UTF-8)
- [guides/work-rules.md](guides/work-rules.md): change style, review focus, general rules
