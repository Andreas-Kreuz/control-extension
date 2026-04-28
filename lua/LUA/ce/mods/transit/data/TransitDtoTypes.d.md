# Public-Transport DTO-CeTypes

## CeType `ce.mods.transit.Station`

- Key-ID: `id`
- DtoFactory: `ce.mods.transit.data.TransitDtoFactory.createTransitStationDto`

| Name | Typ      |
| ---- | -------- |
| `id` | `string` |

## CeType `ce.mods.transit.Line`

- Key-ID: `id`
- DtoFactory: `ce.mods.transit.data.TransitDtoFactory.createTransitLineDto`

| Name           | Typ                       |
| -------------- | ------------------------- |
| `id`           | `string`                  |
| `nr`           | `string`                  |
| `trafficType`  | `string`                  |
| `lineSegments` | `TransitLineSegmentDto[]` |

## CeType `ce.mods.transit.ModuleSetting`

- Key-ID: `name`
- DtoFactory: `ce.mods.transit.data.TransitDtoFactory.createTransitModuleSettingDto`

| Name          | Typ       |
| ------------- | --------- |
| `category`    | `string`  |
| `name`        | `string`  |
| `description` | `string`  |
| `type`        | `string`  |
| `value`       | `boolean` |
| `eepFunction` | `string`  |

## CeType `ce.mods.transit.LineName`

- Key-ID: `id`
- DtoFactory: `ce.mods.transit.data.TransitDtoFactory.createTransitLineNameDto`

| Name           | Typ                       |
| -------------- | ------------------------- |
| `id`           | `string`                  |
| `nr`           | `string`                  |
| `trafficType`  | `string`                  |
| `lineSegments` | `TransitLineSegmentDto[]` |

## CeType `ce.mods.transit.TransitTrain`

- Key-ID: `id`
- DtoFactory: `ce.mods.transit.data.TransitTrainDtoFactory.createFullDto`

| Name           | Typ                            |
| -------------- | ------------------------------ |
| `id`           | `string`                       |
| `line`         | `string`                       |
| `destination`  | `string`                       |
| `origin`       | `string`                       |
| `direction`    | `string`                       |
| `nextStations` | `TransitTrainNextStationDto[]` |

`nextStations` wird per Default nur fuer selektierte Zuege veroeffentlicht (`oninterest`).
Ein Eintrag hat die Form `{ station = { name = string, platform = string }, departureInMinutes = number }`.
