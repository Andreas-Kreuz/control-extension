# RollingStockResourceParser

This parser reads rolling stock metadata from neighboring `.ini` and `.3dm`
resource files. Its main job is to produce the EEP-visible axis list used by
Control Extension.

For rolling stock axis parsing in a real EEP layout, Control Extension needs the
current `.anl3` file path in the global options. The `.anl3` discovery provides
the rolling stock XML model paths that are later used to locate neighboring
`.ini` and `.3dm` resource files.

```lua
local ControlExtension = require("ce.ControlExtension").setOptions({
    anl3path = "C:\\Spiele\\Trend\\EEP18\\Resourcen\\Anlagen\\meine-anlage.anl3"
})
```

This document is also a research log for the reverse-engineered `.3dm` axis
parsing. It should contain enough context for future work without needing the
original investigation chat.

## Axis Sources

Rolling stock axis names can come from two places:

- `.ini` files contain localized entries like `MovAxis8_GER = "Heckfluegel"`.
- `.3dm` files contain structural/control records embedded in the binary model.

When an `.ini` file contains `MovAxis*_LANG` entries, those names are normally
the EEP-visible/API names. The `MovAxis<N>` number is not treated as the runtime
axis number. When an INI entry can be matched to a public `.3dm` control, the
`.3dm` source order is used for runtime numbering.

When the `.ini` file has no `MovAxis` entries, public `.3dm` control records are
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

Case-only INI/model differences are treated as the same control. If the INI says
`fahrer` but the `.3dm` control is `Fahrer`, the parser keeps the `.3dm` casing
and uses the `.3dm` source order. This matches verified EEP behavior for models
where the axis picker shows `Taxi_Licht (#1)` before `Fahrer (#2)`.

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

## 0A Control Records

Some EEP-visible controls are not stored as the older structural axis records.
The parser also recognizes a second record shape whose record type is `0A`
immediately before the same matrix-size marker:

```text
0A 00 00 00
04 00 00 00 04 00 00 00
...
<uint32 little-endian name length>
<ASCII control name>
```

These records are treated as candidate public controls when their names pass the
same identifier checks as structural axis names. This is needed for controls
such as `Voll-Ladung-Leer` and other `0A`-only axes seen in EEP screenshots.

`parsed3dmControls` contains the merged public/internal control diagnostics from
both sources. Each entry records whether it came from `09`, `0A`, or both.

## Public And Internal 3DM Controls

The current rule is:

- names starting with `_` are internal axes;
- all other names are public axis candidates.

Important: an internal `.3dm` axis can still be made visible by an `.ini`
`MovAxis*_LANG` entry. Therefore `_` only affects the fallback case where no
`.ini` axis names exist.

## Runtime Axis Numbers

EEP exposes visible rolling stock axes as a compact list numbered `1..N`.
Current EEP screenshots show that the axis picker rows are sorted by displayed
axis name, with digits before letters, but the number shown behind each row is
the actual runtime axis number.

Therefore:

- `.ini` `MovAxis<N>` is source metadata, not the runtime `ByNumber` slot.
- `.3dm` structural `index` is source metadata, not the runtime `ByNumber` slot.
- `axisNames` is the compact Control Extension / EEP control-axis map.
- For INI axes that match public `.3dm` controls, compact runtime numbers follow
  merged public `.3dm` control source order.
- INI axes that the current `.3dm` parser cannot match are kept visible and
  appended in ascending `MovAxis<N>` source order.
- For `.3dm` fallback axes, compact runtime numbers follow accepted public
  control record order, including `09` structural axes and `0A` controls.

Example compact result:

```lua
axisNames = {
    [1] = "Rollen-li-re",
    [2] = "Neigen",
    [3] = "Landelicht-Aus-Ein"
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

EEP UI screenshot showed the rows alphabetically, but with these runtime
numbers:

```text
Blinklicht (#2)
Bruecke_heben (#3)
Fahrer (#1)
Kran_Ausfahren (#7)
Kran_drehen (#4)
Kran-Arm_1 (#5)
Kran-Arm_2 (#6)
Stuetzen_ausfahren (#8)
Stuetzen_runter (#9)
```

Manual parser verification against the installed `.ini` and `.3dm` files showed
the model is INI-backed. The compact axis numbers follow ascending `MovAxis<N>`
source order:

```text
1 Fahrer
2 Blinklicht
3 Bruecke_heben
4 Kran_drehen
5 Kran-Arm_1
6 Kran-Arm_2
7 Kran_ausfahren
8 Stuetzen_ausfahren
9 Stuetzen_runter
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

EEP UI showed 13 alphabetically sorted rows:

```text
Bodenlicht-Aus-Ein (#10)
Bremsklappen-Ab-Auf (#8)
Fahrwerk-Ab-Auf (#6)
Flaps-0-30 (#7)
Landelicht-Aus-Ein (#3)
LK-HR-Zu-Auf (#4)
LK-VR-Zu-Auf (#5)
Logo-Lights-Aus-Ein (#11)
Neigen (#2)
Pos-Light-Aus-Ein (#9)
Rollen-li-re (#1)
Strobe-Lights-Aus-Ein (#12)
Triebwerke-Aus-Ein (#13)
```

Important observation:

- `EEPRollingstockSetAxisByNumber` works for compact numbers `1..13`.
- The original large `MovAxis<N>` numbers such as `79` are source metadata, not
  runtime numbers.
- The visible UI row order is alphabetical, but the `(#N)` suffix follows
  compact ascending `MovAxis<N>` source order.

Likely runtime mapping:

```text
1  Rollen-li-re
2  Neigen
3  Landelicht-Aus-Ein
4  LK-HR-Zu-Auf
5  LK-VR-Zu-Auf
6  Fahrwerk-Ab-Auf
7  Flaps-0-30
8  Bremsklappen-Ab-Auf
9  Pos-Light-Aus-Ein
10 Bodenlicht-Aus-Ein
11 Logo-Lights-Aus-Ein
12 Strobe-Lights-Aus-Ein
13 Triebwerke-Aus-Ein
```

Conclusion: `MovAxis<N>` is not runtime `ByNumber`; EEP builds a compact
source-order runtime list and displays that list alphabetically in the picker.

### DBAG_Fals-105

Path:

```text
Resourcen/Rollmaterial/Schiene/Gueterwaggons/DBAG_Fals-105.ini
```

EEP UI showed 5 alphabetically sorted rows:

```text
Aus-Kohlenstaub_Ein (#4)
Schlusstafel_H (#3)
Schlusstafel_V (#2)
Voll-Ladung-Leer (#5)
Zu<Klappen>Auf (#1)
```

Current `.3dm` parser finds:

```text
1 Zu<Klappen>Auf
2 Schlusstafel_V
3 Schlusstafel_H
4 Aus-Kohlenstaub_Ein
5 Voll-Ladung-Leer
```

Important observation:

- `Voll-Ladung-Leer` is a `0A` control, not an old structural `09` axis record.
- The found structural axes match EEP runtime numbers, so `.3dm` fallback order
  is source order for this verified example.

Conclusion: old/no-INI models need the merged `09` plus `0A` public control
order.

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
- This only describes the picker row order, not runtime `ByNumber` order.

The exact locale/collation behavior for umlauts and unusual punctuation is not
fully proven.

## Parser Output

`infoForXmlModel()` returns:

- `axisNames`: compact visible axis names, German/default view.
- `axisNamesByLanguage`: compact visible axis names by language.
- `rawAxisNames`: original German `MovAxis<N>` names from `.ini`.
- `rawAxisNamesByLanguage`: original localized `MovAxis<N>` names from `.ini`.
- `parsed3dmAxes`: structural `.3dm` axis records.
- `parsed3dmControls`: merged `.3dm` control records from `09` and `0A`.
- `visibleAxisInfos`: compact visible axis entries with source metadata.
- `textureNames`: parsed texture text names.
- `parserError`: optional non-fatal parse error text.

`visibleAxisInfos` entries look like:

```lua
{
    axisNumber = 1,             -- compact runtime/display order
    name = "Heckfluegel",       -- visible axis name
    source = "ini+3dm",         -- "ini", "3dm", or "ini+3dm"
    sourceNumber = 8,           -- original MovAxis number or .3dm control index
    source3dmName = "Spoiler",  -- optional matched .3dm control name
    source3dmRecordTypes = {    -- optional matched .3dm record sources
        ["09"] = true,
        ["0A"] = true
    }
}
```

## Do Not Assume

- Do not assume `.ini` `MovAxis<N>` is the runtime number.
- Do not assume `.3dm` structural `index` is the runtime number.
- Do not assume the alphabetically sorted picker row order is runtime number
  order; use the `(#N)` suffix from EEP screenshots/runtime tests instead.
- Do not assume all EEP-visible axes are found by the current `.3dm` parser.
- Do not assume `_` means an axis can never be visible; `.ini` can publish an
  internal `.3dm` axis under a visible name.
- Do not assume `.3dm` names override `.ini` names except for case-only
  differences. Runtime EEP name access usually follows the visible INI name, and
  verified examples show `.ini` names win when the names meaningfully differ.
- Do not assume name normalization is safe for control. Use exact visible names.

## Known Limits

The `.3dm` format is not fully documented here. The parser records the structure
that was observed in EEP rolling stock models and verified against EEP runtime
behavior. Some model controls, especially group/load-style controls, may use
additional structures that need more examples before they can be parsed with the
same confidence.

Known open questions:

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
