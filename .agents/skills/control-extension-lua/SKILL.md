---
name: control-extension-lua
description: Project-specific workflow for Lua work in the control-extension repository. Use when Codex edits, reviews, tests, formats, or reasons about `.lua` files under `lua/LUA`, Lua specs, EEP runtime integration, DataBridge transport files, Lua DTO factories/types/docs, or Lua-to-server contract changes in control-extension.
---

# Control Extension Lua

## Required Reading

Before modifying Lua, read:

1. `project-docs/ai/encoding/rules.md`
2. `project-docs/ai/guides/work-rules.md`
3. `project-docs/ai/guides/lua-runtime.md`

Also read the domain guide that matches the task:

- DataBridge or exchange files: `project-docs/ai/guides/lua-databridge.md`
- DTO, `ceType`, `keyId`, factory, or server boundary changes: `project-docs/ai/guides/lua-server-contract.md`
- EEP rolling stock metadata, axis names, texture/tag extraction: `project-docs/ai/guides/lua-rollingstock-models.md`
- Commands before running unfamiliar scripts: `project-docs/ai/guides/commands.md`

## Workflow

1. Inspect the affected Lua module and nearby specs under `lua/LUA/spec`.
2. Keep patches local and minimal. Preserve German identifiers, comments, and log text.
3. Treat EEP calls as expensive. Prefer cached state, watched registries, idempotent setters, and narrow polling.
4. Preserve fail-loud EEP error paths such as `print(... debug.traceback())`.
5. For persistent state, use `StorageUtility.loadTable()` / `StorageUtility.saveTable()` patterns and omit absent optional fields instead of storing `"nil"`.
6. Respect global callback registration patterns using `_G[...]`.
7. Prefer chainable command methods for classes when it improves readability and matches nearby APIs.
8. For DTO or contract changes, update Lua type definitions, Lua DTO docs, factories, matching server `*LuaDto` types, and affected server docs together.
9. After Lua changes, run `cmd /c yarn run format:lua` before checks.

## Specs

- In Lua spec files, stub `print` with `local printStub = stub(_G, "print")` when output should be suppressed or asserted, and restore it after the test with `printStub:revert()`.

## Encoding

- `.lua` files are Latin1 / ISO-8859-1.
- Files in `lua/LUA/ce/databridge/exchange/` are Latin1.
- Files in `apps/web-app/cypress/fixtures/*/*.json` are Latin1.
- All other files are UTF-8.

When editing Latin1 files, use tools and commands that preserve the existing encoding. After modifying Lua files that may contain German text, check that replacement characters were not introduced.

## Validation

For Lua-only changes, prefer this sequence:

```powershell
cmd /c yarn run format:lua
cmd /c yarn run check:lua
```

When running LuaLS manually, write temporary configs and logs outside the repository, for example under
`C:\tmp\luals-control-extension`. Use `--logpath="C:\tmp\luals-control-extension"` and, if a temporary config is
needed, `--configpath="C:\tmp\luals-control-extension\.luarc-ce.tmp.json"`.

For narrower checks:

```powershell
luacheck --config lua/.luacheckrc lua/LUA
busted --config-file lua/.busted --verbose --
```

If Lua tooling is unavailable in the sandbox, perform static inspection, run whatever targeted checks are available, and state exactly which validation could not be executed.
