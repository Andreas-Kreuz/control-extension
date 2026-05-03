# Lua Rolling Stock Models

Use for `lua/LUA/ce/hub/data/rollingstock/Model*.lua`.

Encoding: [rules.md](../encoding/rules.md).

## Metadata

- AI approach: find the `.ini` beside the `.3dm` under `C:\Spiele\EEP18\Resourcen\Rollmaterial`.
- LUA approach: find the `.ini` beside the `.3dm` under `Resourcen\Rollmaterial` - the Resourcen folder of the game is located parallel to the LUA folder (in project lua/LUA)
- Each axis and texture test has an index and a multilanguage key, we use the <\_GER> key for extraction
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
