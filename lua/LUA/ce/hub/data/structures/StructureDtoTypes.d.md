# Structure DTO-CeType

## CeType `ce.hub.Structure`

- Key-ID: `id`
- DtoFactory: `ce.hub.data.structures.StructureDtoFactory`

| Name            | Typ       |
| --------------- | --------- |
| `id`            | `string`  |
| `name`          | `string`  |
| `pos_x`         | `number`  |
| `pos_y`         | `number`  |
| `pos_z`         | `number`  |
| `rot_x`         | `number`  |
| `rot_y`         | `number`  |
| `rot_z`         | `number`  |
| `modelType`     | `number`  |
| `modelTypeText` | `string`  |
| `tag`           | `string`  |
| `light`         | `boolean` |
| `smoke`         | `boolean` |
| `fire`          | `boolean` |

Hinweis:

- Die Discovery nimmt nur Strukturen in die Registry auf, für die dynamische Zustände wie `light`, `smoke` oder `fire` relevant sind.
- Im `selected`-Modus können die dynamischen Felder bei nicht selektierten Objekten mit Platzhalterwerten gesendet werden.
