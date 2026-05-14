# Signal DTO-CeTypes

## CeType `ce.hub.Signal`

- Key-ID: `id`
- DtoFactory: `ce.hub.data.ce.hub.Signal.SignalDtoFactory`

| Name                    | Typ        |
| ----------------------- | ---------- |
| `id`                    | `number`   |
| `position`              | `number`   |
| `tag`                   | `string`   |
| `waitingVehiclesCount`  | `number`   |
| `stopDistance`          | `number`   |
| `itemName`              | `string`   |
| `itemNameWithModelPath` | `string`   |
| `signalFunctions`       | `string[]` |
| `activeFunction`        | `string`   |

Hinweis: `waitingVehiclesCount` wird standardmäßig nur bei Interesse mit echtem Wert veröffentlicht.
Nicht ausgewählte Einträge enthalten den Platzhalter `0`.

## CeType `ce.hub.WaitingOnSignal`

- Key-ID: `id`
- DtoFactory: `ce.hub.data.ce.hub.Signal.SignalDtoFactory`

| Name              | Typ      |
| ----------------- | -------- |
| `id`              | `string` |
| `signalId`        | `number` |
| `waitingPosition` | `number` |
| `vehicleName`     | `string` |
| `waitingCount`    | `number` |

Hinweis: `waitingPosition`, `vehicleName` und `waitingCount` werden standardmäßig nur bei Interesse
mit echten Werten veröffentlicht. Nicht ausgewählte vollständige DTOs enthalten Platzhalterwerte
(`0` beziehungsweise `""`); Patch-DTOs lassen diese Felder ohne Interesse weg.
