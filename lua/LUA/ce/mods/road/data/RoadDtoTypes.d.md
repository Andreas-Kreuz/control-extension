# Road DTO-CeTypes

## CeType `ce.mods.road.Intersection`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createRoadIntersectionDto`

| Name               | Typ           |
| ------------------ | ------------- |
| `id`               | `number`      |
| `name`             | `string`      |
| `currentSwitching` | `string\|nil` |
| `manualSwitching`  | `string\|nil` |
| `nextSwitching`    | `string\|nil` |
| `ready`            | `boolean`     |
| `timeForGreen`     | `number`      |
| `staticCams`       | `table`       |

## CeType `ce.mods.road.IntersectionLane`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createRoadIntersectionLaneDto`

| Name                         | Typ      |
| ---------------------------- | -------- |
| `id`                         | `string` |
| `intersectionId`             | `number` |
| `name`                       | `string` |
| `phase`                      | `string` |
| `vehicleMultiplier`          | `number` |
| `eepSaveId`                  | `number` |
| `type`                       | `string` |
| `countType`                  | `string` |
| `waitingTrains`              | `table`  |
| `waitingForGreenCyclesCount` | `number` |
| `directions`                 | `table`  |
| `switchings`                 | `table`  |
| `tracks`                     | `table`  |

## CeType `ce.mods.road.IntersectionSwitching`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createRoadIntersectionSwitchingDto`

| Name             | Typ              |
| ---------------- | ---------------- |
| `id`             | `string`         |
| `intersectionId` | `string\|number` |
| `name`           | `string`         |
| `prio`           | `number`         |

## CeType `ce.mods.road.IntersectionTrafficLight`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createRoadIntersectionTrafficLightDto`

| Name              | Typ                                                   |
| ----------------- | ----------------------------------------------------- |
| `id`              | `number`                                              |
| `signalId`        | `number`                                              |
| `modelId`         | `string`                                              |
| `currentPhase`    | `string`                                              |
| `intersectionId`  | `number`                                              |
| `lightStructures` | `table<string, IntersectionTrafficLightStructureDto>` |
| `axisStructures`  | `IntersectionTrafficLightAxisStructureDto[]`          |

## CeType `ce.mods.road.ModuleSetting`

- Key-ID: `name`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createRoadIntersectionModuleSettingDto`

| Name          | Typ       |
| ------------- | --------- |
| `category`    | `string`  |
| `name`        | `string`  |
| `description` | `string`  |
| `type`        | `string`  |
| `value`       | `boolean` |
| `eepFunction` | `string`  |

## CeType `ce.mods.road.SignalTypeDefinition`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.TrafficLightModelDtoFactory.createSignalTypeDefinitionDto`

| Name        | Typ                                |
| ----------- | ---------------------------------- |
| `id`        | `string`                           |
| `name`      | `string`                           |
| `type`      | `string`                           |
| `positions` | `SignalTypeDefinitionPositionsDto` |
