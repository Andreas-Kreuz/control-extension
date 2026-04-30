# RollingStockResourceParser

This parser reads rolling stock metadata from neighboring `.ini` and `.3dm`
resource files. Its main job is to produce the EEP-visible axis list used by
Control Extension.

This document is also a research log for the reverse-engineered `.3dm` axis
parsing. It should contain enough context for future work without needing the
original investigation chat.

## Axis Sources

Rolling stock axis names can come from two places:

- `.ini` files contain localized entries like `MovAxis8_GER = "Heckfluegel"`.
- `.3dm` files contain structural axis records embedded in the binary model.

When an `.ini` file contains `MovAxis*_LANG` entries, those names are treated as
the authoritative EEP-visible/API names. The `MovAxis<N>` number is not treated
as the runtime axis number.

When the `.ini` file has no `MovAxis` entries, public `.3dm` axis records are
used as the visible axis names.

## INI Axis Meaning

Example:

```ini
MovAxis8_GER = "Heckfluegel"
```

Observed EEP behavior:

- `Heckfluegel` is the name shown by EEP.
- `Heckfluegel` is the name accepted by `EEPRollingstockGetAxis`.
- `Heckfluegel` is the name accepted by `EEPRollingstockSetAxis`.
- `8` is not necessarily accepted by `EEPRollingstockSetAxisByNumber`.

The parser therefore keeps two views:

- `rawAxisNames` / `rawAxisNamesByLanguage`: original `MovAxis<N>` numbers.
- `axisNames` / `axisNamesByLanguage`: compact EEP-visible axis map.

## 3DM Axis Structure

The `.3dm` parser does not search arbitrary text names. It looks for structural
axis records near a binary marker:

```text
04 00 00 00 04 00 00 00
```

After this marker, the parser scans a short window for records shaped like:

```text
<axis transform data>
<uint32 little-endian name length>
<ASCII axis name>
```

The structural index used by `parsed3dmAxes[index]` is the 1-based order in
which these accepted records are found. It is not the EEP runtime axis number.

Additional heuristics currently used:

- The 128 bytes before the name-length field must contain at least three
  little-endian float `1.0` values: `00 00 80 3F`.
- The 48 bytes before the name-length field must not already contain a readable
  word-like ASCII sequence.
- Axis names are accepted only if they look like model axis identifiers:
  letters/digits/space and common punctuation such as `_`, `-`, `<`, `>`, `:`.
- Very close names inside the previous axis record are rejected as embedded
  reference names, not standalone axes.

The parser currently records the offset of the name-length field, not the start
of the whole axis structure.

Each accepted `.3dm` axis record is returned as:

```lua
{
    index = 1,        -- structural .3dm record order, 1-based
    name = "Fahrer", -- raw .3dm axis name
    isPublic = true, -- false when the name starts with "_"
    offset = 12345   -- byte offset of the name-length field
}
```

## Public And Internal 3DM Axes

The current rule is:

- names starting with `_` are internal axes;
- all other names are public axis candidates.

Important: an internal `.3dm` axis can still be made visible by an `.ini`
`MovAxis*_LANG` entry. Therefore `_` only affects the fallback case where no
`.ini` axis names exist.

## Runtime Axis Numbers

EEP exposes visible rolling stock axes as a compact list numbered `1..N`.
Current EEP tests show this compact list is sorted by the displayed axis name,
with digits before letters.

Therefore:

- `.ini` `MovAxis<N>` is source metadata, not the runtime `ByNumber` slot.
- `.3dm` structural `index` is source metadata, not the runtime `ByNumber` slot.
- `axisNames` is the compact Control Extension / EEP-visible axis map.

Example compact result:

```lua
axisNames = {
    [1] = "Bodenlicht-Aus-Ein",
    [2] = "Bremsklappen-Ab-Auf",
    [3] = "Fahrwerk-Ab-Auf"
}
```

## Verified Examples

### ADAC_PKW_Abschlepper

Path:

```text
Resourcen.unp/Rollmaterial/Strasse/LKW/ADAC_PKW_Abschlepper.ini
Resourcen.unp/Rollmaterial/Strasse/LKW/ADAC_PKW_Abschlepper.3dm
```

Important observation:

- `.ini` names and `.3dm` names can differ only by punctuation/case.
- `.3dm` public axis names look more authoritative as model-internal names.
- EEP-visible/API names are still the `.ini` names when `.ini` publishes them.

Observed `.3dm` public axes included:

```text
6:Fahrer
7:Blinklicht
12:Bruecke-Heben
14:KranDrehen
15:Kran_Arm_1
16:Kran_Arm_2
17:Kran_Ausfahren
28:Stuetzen-Ausfahren
29:Stuetzen-Runter
```

### Atti_Veron_black

Path:

```text
Resourcen/Rollmaterial/Strasse/PKW/Atti_Veron_black.ini
```

Important observation:

- `.ini`: `MovAxis8_GER = "Heckfluegel"` (real file uses German umlaut).
- `.3dm`: internal/model name looked like `Spoiler`.
- EEP accepts `EEPRollingstockSetAxis(..., "Heckfluegel", value)`.
- EEP did not accept the differing `.3dm` name as the visible API name.

Conclusion: when `.ini` names exist, they are the visible/API names even if the
`.3dm` name is semantically better or more model-internal.

### B747-400-LH-VM_RP1

Path:

```text
Resourcen/Rollmaterial/Luft/B747-400-LH-VM_RP1.ini
```

EEP UI showed 13 axes:

```text
Bodenlicht-Aus-Ein
Bremsklappen-Ab-Auf
Fahrwerk-Ab-Auf
Flaps-0-30
Landelicht-Aus-Ein
LK-HR-Zu-Auf
LK-VR-Zu-Auf
Logo-Lights-Aus-Ein
Neigen
Pos-Light-Aus-Ein
Rollen-li-re
Strobe-Lights-Aus-Ein
Triebwerke-Aus-Ein
```

Important observation:

- `EEPRollingstockSetAxisByNumber` worked for compact numbers `1..13`.
- It did not work for the original large `MovAxis<N>` numbers such as `79`.
- The compact order matched the visible names sorted alphabetically.

Likely runtime mapping:

```text
1  Bodenlicht-Aus-Ein
2  Bremsklappen-Ab-Auf
3  Fahrwerk-Ab-Auf
4  Flaps-0-30
5  Landelicht-Aus-Ein
6  LK-HR-Zu-Auf
7  LK-VR-Zu-Auf
8  Logo-Lights-Aus-Ein
9  Neigen
10 Pos-Light-Aus-Ein
11 Rollen-li-re
12 Strobe-Lights-Aus-Ein
13 Triebwerke-Aus-Ein
```

Conclusion: `MovAxis<N>` is not runtime `ByNumber`; EEP builds a compact sorted
visible-axis list.

### DBAG_Fals-105

Path:

```text
Resourcen/Rollmaterial/Schiene/Gueterwaggons/DBAG_Fals-105.ini
```

EEP UI showed 5 axes:

```text
Aus-Kohlenstaub_Ein
Schlusstafel_H
Schlusstafel_V
Voll-Ladung-Leer
Zu<Klappen>Auf
```

Current structural `.3dm` parser finds at least:

```text
Zu<Klappen>Auf
Schlusstafel_V
Schlusstafel_H
Aus-Kohlenstaub_Ein
```

Important open gap:

- `Voll-Ladung-Leer` exists in the `.3dm` file but did not match the current
  structural axis record parser.
- It appears to be a different control class, probably load/group-style data.

Conclusion: the current `.3dm` parser finds many structural axis records, but
not every EEP-visible control in old/no-INI models.

### PKP_Smms-481

Path:

```text
Resourcen/Rollmaterial/Schiene/Gueterwaggons/PKP_Smms-481.ini
```

Important observation:

- EEP exposes `Schlusstafel_H` and `Schlusstafel_V`.
- These can be discovered from `.3dm` when `.ini` has no axis information.

Conclusion: `.3dm` fallback is needed for models whose `.ini` does not publish
`MovAxis` entries.

### Numeric-Leading Axis Names

Example EEP UI order:

```text
0m =Strom= 5m === 6m =
Fahrgast
```

Important observation:

- Digits sort before letters in EEP's visible-axis order.
- This matches simple lexical sorting for the tested examples.

The exact locale/collation behavior for umlauts and unusual punctuation is not
fully proven.

## Parser Output

`infoForXmlModel()` returns:

- `axisNames`: compact visible axis names, German/default view.
- `axisNamesByLanguage`: compact visible axis names by language.
- `rawAxisNames`: original German `MovAxis<N>` names from `.ini`.
- `rawAxisNamesByLanguage`: original localized `MovAxis<N>` names from `.ini`.
- `parsed3dmAxes`: structural `.3dm` axis records.
- `visibleAxisInfos`: compact visible axis entries with source metadata.
- `textureNames`: parsed texture text names.
- `parserError`: optional non-fatal parse error text.

`visibleAxisInfos` entries look like:

```lua
{
    axisNumber = 1,       -- compact runtime/display order
    name = "Heckfluegel", -- visible axis name
    source = "ini",       -- "ini" or "3dm"
    sourceNumber = 8      -- original MovAxis number or .3dm structural index
}
```

## Do Not Assume

- Do not assume `.ini` `MovAxis<N>` is the runtime number.
- Do not assume `.3dm` structural `index` is the runtime number.
- Do not assume all EEP-visible axes are found by the current `.3dm` parser.
- Do not assume `_` means an axis can never be visible; `.ini` can publish an
  internal `.3dm` axis under a visible name.
- Do not assume `.3dm` names override `.ini` names. Runtime EEP name access
  follows the visible name, and verified examples show `.ini` names win.
- Do not assume name normalization is safe for control. Use exact visible names.

## Known Limits

The `.3dm` format is not fully documented here. The parser records the structure
that was observed in EEP rolling stock models and verified against EEP runtime
behavior. Some model controls, especially group/load-style controls, may use
additional structures that need more examples before they can be parsed with the
same confidence.

Known open questions:

- What exact `.3dm` structure publishes load controls such as
  `Voll-Ladung-Leer`?
- Are group/controller axes always distinguishable from regular axes by nearby
  relation/reference records?
- Does EEP's visible-axis sorting use raw byte order, German locale collation,
  or another internal comparison for umlauts and punctuation?
- Are there model families where `.ini` and `.3dm` are combined differently?

## Recommended Future Investigation

When a future model exposes an EEP-visible axis that the parser misses:

1. Confirm the exact EEP-visible name with `EEPRollingstockGetAxis`.
2. Search the `.3dm` file for the byte string only to locate candidate regions.
3. Inspect the bytes around that region and compare them with known structural
   axis records.
4. Add the newly understood structure to this document before changing parser
   heuristics.
5. Add a parser spec with a minimal binary fixture for the new structure.
