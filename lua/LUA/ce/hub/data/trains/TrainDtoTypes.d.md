# Train DTO-CeTypes

## CeType `ce.hub.Train`

- Key-ID: `id`
- DtoFactory: `ce.hub.data.ce.hub.Train.TrainDtoFactory`

| Name                | Typ           |
| ------------------- | ------------- |
| `id`                | `string`      |
| `route`             | `string`      |
| `rollingStockCount` | `number`      |
| `length`            | `number`      |
| `line`              | `string\|nil` |
| `destination`       | `string\|nil` |
| `direction`         | `string\|nil` |
| `trackType`         | `string\|nil` |
| `movesForward`      | `boolean`     |
| `speed`             | `number`      |
| `targetSpeed`       | `number`      |
| `couplingFront`     | `number`      |
| `couplingRear`      | `number`      |
| `active`            | `boolean`     |
| `trainyardId`       | `number\|nil` |
| `inTrainyard`       | `boolean`     |
| `occupiedTacks`     | `table`       |
