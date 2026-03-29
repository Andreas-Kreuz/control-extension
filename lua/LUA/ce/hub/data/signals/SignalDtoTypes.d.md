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
