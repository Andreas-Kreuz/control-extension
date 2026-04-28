# Lua Rolling Stock Models

Use for `lua/LUA/ce/hub/data/rollingstock/Model*.lua`.

Encoding: [rules.md](../encoding/rules.md).

## Metadata

- Find the `.ini` beside the `.3dm` under `C:\Spiele\EEP18\Resourcen\Rollmaterial`.
- `MovAxis<X>_GER` -> `axisNames`; keep exact spelling.
- `TexText<X>_GER` -> `textureTexts`; `X` is the `EEPRollingstockSetTextureText` index.
- Use one axis / texture per line.

```lua
axisNames = {
    "TuerRechts"
}

textureTexts = {
    [1] = "Liniennummer"
}
```

## Verify

- `python scripts/latin1_check.py <lua-file>`
- `luacheck --config lua/.luacheckrc <lua-file>`
- `busted --config-file lua/.busted --verbose -- spec/ce/hub/data/rollingstock/RollingStockModels_spec.lua`
