# Road DTO-CeTypes

## CeType `ce.mods.road.Intersection`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createIntersectionDto`

| Name                     | Typ                                   |
| ------------------------ | ------------------------------------- |
| `id`                     | `number`                              |
| `name`                   | `string`                              |
| `eepSaveId`              | `number`                              |
| `scriptVariableName`     | `string\|nil`                         |
| `currentPhase`           | `string\|nil`                         |
| `manualPhase`            | `string\|nil`                         |
| `nextPhase`              | `string\|nil`                         |
| `ready`                  | `boolean`                             |
| `greenTimeSeconds`       | `number`                              |
| `tippStructure`          | `string\|nil`                         |
| `staticCams`             | `table`                               |
| `phases`                 | `IntersectionPhaseDto[]`              |
| `signalGroupDefinitions` | `IntersectionSignalGroupDto[]`        |
| `pedestrianCrossings`    | `IntersectionPedestrianCrossingDto[]` |

### `IntersectionSignalGroupDto`

| Name                      | Typ           |
| ------------------------- | ------------- |
| `name`                    | `string`      |
| `scriptVariableName`      | `string\|nil` |
| `approach`                | `string\|nil` |
| `turnDirections`          | `table`       |
| `trafficType`             | `string`      |
| `signalIds`               | `number[]`    |
| `pedestrianCrossingNames` | `string[]`    |

### `IntersectionPedestrianCrossingDto`

| Name                 | Typ           |
| -------------------- | ------------- |
| `name`               | `string`      |
| `scriptVariableName` | `string\|nil` |
| `approach`           | `string`      |
| `signalGroups`       | `string[]`    |

### `IntersectionPhaseDto`

| Name               | Typ                                |
| ------------------ | ---------------------------------- |
| `id`               | `string`                           |
| `name`             | `string`                           |
| `order`            | `number`                           |
| `prio`             | `number`                           |
| `greenTimeSeconds` | `number`                           |
| `signalHeads`      | `IntersectionPhaseSignalHeadDto[]` |

### `IntersectionPhaseSignalHeadDto`

| Name                       | Typ           |
| -------------------------- | ------------- |
| `signalId`                 | `number`      |
| `signalHeadKind`           | `string`      |
| `signalHeadKey`            | `string`      |
| `signalHeadName`           | `string\|nil` |
| `type`                     | `string`      |
| `vehicleSignalHeadName`    | `string\|nil` |
| `pedestrianSignalHeadName` | `string\|nil` |
| `use`                      | `string`      |

## CeType `ce.mods.road.IntersectionLane`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createIntersectionLaneDto`

| Name                         | Typ           |
| ---------------------------- | ------------- |
| `id`                         | `string`      |
| `intersectionId`             | `number`      |
| `name`                       | `string`      |
| `scriptVariableName`         | `string\|nil` |
| `currentIndication`          | `string`      |
| `vehicleMultiplier`          | `number`      |
| `laneSignalId`               | `number`      |
| `type`                       | `string`      |
| `countType`                  | `string`      |
| `waitingTrains`              | `table`       |
| `waitingForGreenCyclesCount` | `number`      |
| pproach                      | string        |
| `directions`                 | `table`       |
| `phases`                     | `table`       |
| `defaultSignalGroups`        | `table`       |
| `defaultRequestSignalGroups` | `table`       |
| `requestTrackIds`            | `table`       |
| `highlightTrackIds`          | `table`       |
| `tracks`                     | `table`       |

## CeType `ce.mods.road.IntersectionPhase`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createIntersectionPhaseDto`

| Name             | Typ              |
| ---------------- | ---------------- |
| `id`             | `string`         |
| `intersectionId` | `string\|number` |
| `name`           | `string`         |
| `prio`           | `number`         |

## CeType `ce.mods.road.IntersectionTrafficLight`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createIntersectionTrafficLightDto`

| Name                   | Typ                                                   |
| ---------------------- | ----------------------------------------------------- |
| `id`                   | `number`                                              |
| `signalId`             | `number`                                              |
| `vehicleSignalName`    | `string\|nil`                                         |
| `pedestrianSignalName` | `string\|nil`                                         |
| `use`                  | `string`                                              |
| `modelId`              | `string`                                              |
| `currentIndication`    | `string`                                              |
| `intersectionId`       | `number`                                              |
| `lightStructures`      | `table<string, IntersectionTrafficLightStructureDto>` |
| `axisStructures`       | `IntersectionTrafficLightAxisStructureDto[]`          |

## CeType `ce.mods.road.ModuleSetting`

- Key-ID: `name`
- DtoFactory: `ce.mods.road.data.RoadDtoFactory.createIntersectionModuleSettingDto`

| Name          | Typ       |
| ------------- | --------- |
| `category`    | `string`  |
| `name`        | `string`  |
| `description` | `string`  |
| `type`        | `string`  |
| `value`       | `boolean` |
| `eepFunction` | `string`  |

## CeType `ce.mods.road.TrafficLightModel`

- Key-ID: `id`
- DtoFactory: `ce.mods.road.data.TrafficLightModelDtoFactory.createTrafficLightModelDto`

| Name        | Typ                             |
| ----------- | ------------------------------- |
| `id`        | `string`                        |
| `name`      | `string`                        |
| `type`      | `string`                        |
| `positions` | `TrafficLightModelPositionsDto` |
