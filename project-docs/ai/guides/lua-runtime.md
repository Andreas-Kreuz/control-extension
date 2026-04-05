# Lua / EEP Runtime Guide

## Runtime

- Production code: `lua/LUA/ce` — runs in Lua 5.3 inside EEP
- EEP provides globals like `EEPSetSignal`, `EEPLoadData`, `EEPTime` (see `LUA_Manual.pdf`)
- Installed path: `C:\Trend\EEP18\LUA` (version-dependent)
- Keep existing German identifiers, comments, and log messages when modifying Lua code

## EepOriginalApi

- `lua/LUA/ce/hub/eep/EepOriginalApi.d.lua` is the type-safe reference of the original EEP API
- Derived from `Lua_manual.pdf` (parsed with `pdftotext -table`, block-based table parser), NOT from `EepSimulator.lua`
- `EepSimulator.lua` mirrors EEP program functions so Lua code can be tested outside EEP
- Only generator: `python scripts/generate_eep_original_api.py`
- Contains only definitions: global variables as `---@type` with placeholder values, callbacks and functions as empty bodies. No simulator logic.
- Value ranges from manual remarks should be modeled as `---@alias`, placed above the first function that uses them
- After each function/callback, include manual examples as `-- Beispielaufrufe:` comment block
- Block types in the manual: variable blocks and function/callback blocks
- After regeneration, verify with:
  - `lua -e "assert(loadfile('lua/LUA/ce/hub/eep/EepOriginalApi.d.lua')); print('OK')"`
  - Consistency check: every function/callback has a version line and `-- Beispielaufrufe:` block; parameter/return counts match manual ranges; no placeholder names like `paramN`

## State and Persistence

- Persistent state uses EEP data slots via `StorageUtility.loadTable()` / `StorageUtility.saveTable()` — accepts string values only
- Omit optional fields when saving rather than writing `"nil"` placeholders
- Short slot keys: `b`, `z`, `r`, `t`
- Hard resets and recovery paths are critical — new stateful objects must define reset behavior
- Many modules register global callbacks via `_G[...]` — respect existing naming conventions

## Error Handling

- EEP-facing error paths are intentionally fail-loud: preserve existing `print(... debug.traceback())` patterns

## Commands

- Install dependencies: `yarn`
- Available root scripts: `yarn ce-help`
- Lint: `luacheck --config lua/.luacheckrc lua/LUA`
- Test: `busted --config-file lua/.busted --verbose --`
- Test with coverage: `busted --config-file lua/.busted --verbose --coverage --`
- Format: `yarn format:lua` (uses `scripts/format-lua-with-sumneko.mjs`, excludes `anlagen`/`demo-anlagen` dirs)
- Format uses locally installed VSCode Lua Language Server (`sumneko.lua`); set `VSCODE_EXTENSIONS` if non-standard path

## Testing

- Check affected specs under `lua/LUA/spec` first
- After changes, run luacheck + busted if runtime is available
- If runtime unavailable, verify statically and state what could not be executed
- After changes run `yarn format:lua` if only Lua files are affected
