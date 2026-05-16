---@meta

---@class IntersectionDto
---@field ceType string
---@field id number
---@field name string
---@field currentPhase string|nil
---@field manualPhase string|nil
---@field nextPhase string|nil
---@field ready boolean
---@field greenTimeSeconds number
---@field staticCams table
---@field phases IntersectionPhaseTimingDto[]

---@class IntersectionPhaseSignalHeadDto
---@field signalId number
---@field signalHeadKind string
---@field signalHeadKey string
---@field signalHeadName string|nil
---@field type string
---@field vehicleSignalHeadName string|nil
---@field pedestrianSignalHeadName string|nil
---@field use string

---@class IntersectionPhaseTimingDto
---@field id string
---@field name string
---@field order number
---@field prio number
---@field greenTimeSeconds number
---@field signalGroups string[]
---@field signalHeads IntersectionPhaseSignalHeadDto[]

---@class IntersectionLaneDto
---@field ceType string
---@field id string
---@field intersectionId number
---@field name string
---@field currentIndication string
---@field vehicleMultiplier number
---@field eepSaveId number
---@field type string
---@field countType string
---@field waitingTrains table
---@field waitingForGreenCyclesCount number
---@field directions table
---@field phases table
---@field tracks table

---@class IntersectionPhaseDto
---@field ceType string
---@field id string
---@field intersectionId string|number
---@field name string
---@field prio number

---@class IntersectionTrafficLightStructureDto
---@field structureRed string|nil
---@field structureGreen string|nil
---@field structureYellow string|nil
---@field structureRequest string|nil

---@class IntersectionTrafficLightAxisStructureDto
---@field structureName string
---@field axisName string
---@field positionDefault number
---@field positionRed number|nil
---@field positionGreen number|nil
---@field positionYellow number|nil
---@field positionPedestrian number|nil
---@field positionRedYellow number|nil

---@class IntersectionTrafficLightDto
---@field ceType string
---@field id number
---@field signalId number
---@field vehicleSignalName string|nil
---@field pedestrianSignalName string|nil
---@field use string
---@field modelId string
---@field currentIndication string
---@field intersectionId number
---@field lightStructures table<string, IntersectionTrafficLightStructureDto>
---@field axisStructures IntersectionTrafficLightAxisStructureDto[]

---@class IntersectionModuleSettingDto
---@field ceType string
---@field category string
---@field name string
---@field description string
---@field type string
---@field value boolean
---@field eepFunction string

---@class TrafficLightModelPositionsDto
---@field positionRed number
---@field positionGreen number
---@field positionYellow number
---@field positionRedYellow number
---@field positionPedestrians number
---@field positionOff number
---@field positionOffBlinking number

---@class TrafficLightModelDto
---@field ceType string
---@field id string
---@field name string
---@field type string
---@field positions TrafficLightModelPositionsDto