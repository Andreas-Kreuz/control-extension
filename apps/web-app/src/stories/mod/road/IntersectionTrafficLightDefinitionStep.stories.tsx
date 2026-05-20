import { useState } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import FormControl from '@mui/material/FormControl';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { alpha } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';
import DeleteOutlinedIcon from '@mui/icons-material/DeleteOutlined';
import EastIcon from '@mui/icons-material/East';
import NorthIcon from '@mui/icons-material/North';
import NorthEastIcon from '@mui/icons-material/NorthEast';
import NorthWestIcon from '@mui/icons-material/NorthWest';
import SouthIcon from '@mui/icons-material/South';
import SouthEastIcon from '@mui/icons-material/SouthEast';
import SouthWestIcon from '@mui/icons-material/SouthWest';
import StraightIcon from '@mui/icons-material/Straight';
import TurnLeftIcon from '@mui/icons-material/TurnLeft';
import TurnRightIcon from '@mui/icons-material/TurnRight';
import TurnSlightLeftIcon from '@mui/icons-material/TurnSlightLeft';
import TurnSlightRightIcon from '@mui/icons-material/TurnSlightRight';
import WestIcon from '@mui/icons-material/West';
import type { Meta, StoryObj } from '@storybook/react';
import type {
  IntersectionWizardApproach,
  IntersectionWizardRouteRuleMode,
  IntersectionWizardTurnDirection,
  TrafficLightModelAppDto,
} from '@ce/web-shared';

type TrafficLightFixture = {
  id: string;
  signalId: string;
  ampelName: string;
  modelId: string;
  laneSignal?: boolean;
};

type SignalGroupFixture = {
  id: string;
  name: string;
  routeSelection: string[];
  mode: IntersectionWizardRouteRuleMode;
  turnDirections: IntersectionWizardTurnDirection[];
  lights: TrafficLightFixture[];
  defaultGroup?: boolean;
};

type LaneFixture = {
  id: string;
  name: string;
  approach: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
  laneSignal: TrafficLightFixture;
  signalGroups: SignalGroupFixture[];
};

const turnDirections: IntersectionWizardTurnDirection[] = ['LEFT', 'HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT', 'RIGHT'];
const alwaysRouteLabel = 'routen-unabhängig schalten';
const routeOptions = [alwaysRouteLabel, 'Tram 11 Heiderand', 'Tram 11 Rehfeld', 'Bus 42 Zentrum'];

const approachLabels = {
  NORTH: 'Nord',
  NORTH_EAST: 'Nordost',
  EAST: 'Ost',
  SOUTH_EAST: 'Südost',
  SOUTH: 'Süd',
  SOUTH_WEST: 'Südwest',
  WEST: 'West',
  NORTH_WEST: 'Nordwest',
} satisfies Record<IntersectionWizardApproach, string>;

const approachIcons = {
  NORTH: SouthIcon,
  NORTH_EAST: SouthWestIcon,
  EAST: WestIcon,
  SOUTH_EAST: NorthWestIcon,
  SOUTH: NorthIcon,
  SOUTH_WEST: NorthEastIcon,
  WEST: EastIcon,
  NORTH_WEST: SouthEastIcon,
} satisfies Record<IntersectionWizardApproach, typeof NorthIcon>;

const approachBackgrounds = {
  NORTH: '#eef6ff',
  NORTH_EAST: '#edf8f3',
  EAST: '#fff7e8',
  SOUTH_EAST: '#f7f0ff',
  SOUTH: '#fff0f0',
  SOUTH_WEST: '#f0f4ff',
  WEST: '#f4f6f0',
  NORTH_WEST: '#f0f7f8',
} satisfies Record<IntersectionWizardApproach, string>;

const turnDirectionLabels = {
  LEFT: 'Links',
  HALF_LEFT: 'Halblinks',
  STRAIGHT: 'Geradeaus',
  HALF_RIGHT: 'Halbrechts',
  RIGHT: 'Rechts',
} satisfies Record<IntersectionWizardTurnDirection, string>;

const turnDirectionIcons = {
  LEFT: TurnLeftIcon,
  HALF_LEFT: TurnSlightLeftIcon,
  STRAIGHT: StraightIcon,
  HALF_RIGHT: TurnSlightRightIcon,
  RIGHT: TurnRightIcon,
} satisfies Record<IntersectionWizardTurnDirection, typeof TurnLeftIcon>;

const knownSignalModels: TrafficLightModelAppDto[] = [
  {
    id: 'JS2_3er_mit_FG',
    name: 'JS2_3er_mit_FG',
    type: 'VEHICLE_AND_PEDESTRIAN',
    luaConstant: 'JS2_3er_mit_FG',
    positionRed: 1,
    positionGreen: 2,
    positionYellow: 3,
    positionRedYellow: 4,
    positionPedestrians: 5,
    positionOff: 0,
    positionOffBlinking: 6,
  },
  {
    id: 'JS2_2er_OFF_YELLOW_GREEN',
    name: 'JS2_2er_OFF_YELLOW_GREEN',
    type: 'VEHICLE_ONLY',
    luaConstant: 'JS2_2er_OFF_YELLOW_GREEN',
    positionRed: 1,
    positionGreen: 2,
    positionYellow: 3,
    positionRedYellow: 4,
    positionPedestrians: 0,
    positionOff: 0,
    positionOffBlinking: 5,
  },
  {
    id: 'MA1_STRAB_3er_2_gruen',
    name: 'MA1_STRAB_3er_2_gruen',
    type: 'TRAM',
    luaConstant: 'MA1_STRAB_3er_2_gruen',
    positionRed: 1,
    positionGreen: 2,
    positionYellow: 3,
    positionRedYellow: 4,
    positionPedestrians: 0,
    positionOff: 0,
    positionOffBlinking: 5,
  },
  {
    id: 'Unsichtbar_2er',
    name: 'Unsichtbar_2er',
    type: 'INVISIBLE',
    luaConstant: 'Unsichtbar_2er',
    positionRed: 1,
    positionGreen: 2,
    positionYellow: 0,
    positionRedYellow: 0,
    positionPedestrians: 0,
    positionOff: 0,
    positionOffBlinking: 0,
  },
];

const initialLanes: LaneFixture[] = [
  {
    id: 'lane-fs1',
    name: 'c1Fs1',
    approach: 'NORTH',
    turnDirections: ['STRAIGHT'],
    laneSignal: {
      id: 'light-92',
      signalId: '92',
      ampelName: 'K1',
      modelId: 'JS2_3er_mit_FG',
      laneSignal: true,
    },
    signalGroups: [
      {
        id: 'sg-fs1-straight',
        name: 'nStraight',
        routeSelection: [alwaysRouteLabel],
        mode: 'ONLY',
        turnDirections: ['STRAIGHT'],
        lights: [{ id: 'light-95', signalId: '95', ampelName: 'K4', modelId: 'JS2_3er_mit_FG' }],
        defaultGroup: true,
      },
    ],
  },
  {
    id: 'lane-fs4',
    name: 'c1Fs4',
    approach: 'WEST',
    turnDirections: ['LEFT', 'HALF_LEFT', 'STRAIGHT'],
    laneSignal: {
      id: 'light-89',
      signalId: '89',
      ampelName: 'K3',
      modelId: 'Unsichtbar_2er',
      laneSignal: true,
    },
    signalGroups: [
      {
        id: 'sg-fs4-standard',
        name: 'wLeftHalfLeftStraight',
        routeSelection: [alwaysRouteLabel],
        mode: 'ONLY',
        turnDirections: ['LEFT', 'HALF_LEFT', 'STRAIGHT'],
        lights: [{ id: 'light-90', signalId: '90', ampelName: 'K5', modelId: 'JS2_3er_mit_FG' }],
        defaultGroup: true,
      },
      {
        id: 'sg-fs4-tram',
        name: 'wLeft',
        routeSelection: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'],
        mode: 'ONLY',
        turnDirections: ['LEFT'],
        lights: [{ id: 'light-108', signalId: '108', ampelName: 'S1', modelId: 'MA1_STRAB_3er_2_gruen' }],
      },
      {
        id: 'sg-fs4-bus',
        name: 'wStraight',
        routeSelection: ['Bus 42 Zentrum'],
        mode: 'ALSO',
        turnDirections: ['STRAIGHT'],
        lights: [{ id: 'light-109', signalId: '109', ampelName: 'B1', modelId: 'JS2_2er_OFF_YELLOW_GREEN' }],
      },
    ],
  },
];

function signalModelLabel(model: TrafficLightModelAppDto): string {
  return model.luaConstant ?? model.name;
}

function toggleTurnDirection(
  selectedTurnDirections: IntersectionWizardTurnDirection[],
  turnDirection: IntersectionWizardTurnDirection,
) {
  if (selectedTurnDirections.includes(turnDirection)) {
    return selectedTurnDirections.filter((selectedTurnDirection) => selectedTurnDirection !== turnDirection);
  }
  return [...selectedTurnDirections, turnDirection];
}

function nextLightName(lanes: LaneFixture[]) {
  const lightCount = lanes.reduce(
    (count, lane) => count + 1 + lane.signalGroups.reduce((groupCount, group) => groupCount + group.lights.length, 0),
    0,
  );
  return `K${lightCount + 1}`;
}

function TrafficLightDefinitionPrototype() {
  const [lanes, setLanes] = useState(initialLanes);

  function updateLane(laneId: string, patch: Partial<LaneFixture>) {
    setLanes((current) => current.map((lane) => (lane.id === laneId ? { ...lane, ...patch } : lane)));
  }

  function updateSignalGroup(laneId: string, signalGroupId: string, patch: Partial<SignalGroupFixture>) {
    setLanes((current) =>
      current.map((lane) =>
        lane.id === laneId
          ? {
              ...lane,
              signalGroups: lane.signalGroups.map((group) =>
                group.id === signalGroupId ? { ...group, ...patch } : group,
              ),
            }
          : lane,
      ),
    );
  }

  function updateLight(laneId: string, signalGroupId: string, lightId: string, patch: Partial<TrafficLightFixture>) {
    setLanes((current) =>
      current.map((lane) => {
        if (lane.id !== laneId) return lane;
        if (lane.laneSignal.id === lightId) return { ...lane, laneSignal: { ...lane.laneSignal, ...patch } };
        return {
          ...lane,
          signalGroups: lane.signalGroups.map((group) =>
            group.id === signalGroupId
              ? {
                  ...group,
                  lights: group.lights.map((light) => (light.id === lightId ? { ...light, ...patch } : light)),
                }
              : group,
          ),
        };
      }),
    );
  }

  function addSignalGroup(laneId: string) {
    setLanes((current) =>
      current.map((lane) =>
        lane.id === laneId
          ? {
              ...lane,
              signalGroups: [
                ...lane.signalGroups,
                {
                  id: `sg-${Date.now()}`,
                  name: `${lane.name}Route`,
                  routeSelection: [alwaysRouteLabel],
                  mode: 'ONLY',
                  turnDirections: [lane.turnDirections[0] ?? 'STRAIGHT'],
                  lights: [
                    {
                      id: `light-${Date.now()}`,
                      signalId: '',
                      ampelName: nextLightName(current),
                      modelId: 'JS2_3er_mit_FG',
                    },
                  ],
                },
              ],
            }
          : lane,
      ),
    );
  }

  function deleteSignalGroup(laneId: string, signalGroupId: string) {
    setLanes((current) =>
      current.map((lane) =>
        lane.id === laneId
          ? { ...lane, signalGroups: lane.signalGroups.filter((group) => group.id !== signalGroupId) }
          : lane,
      ),
    );
  }

  function addLight(laneId: string, signalGroupId: string) {
    setLanes((current) =>
      current.map((lane) =>
        lane.id === laneId
          ? {
              ...lane,
              signalGroups: lane.signalGroups.map((group) =>
                group.id === signalGroupId
                  ? {
                      ...group,
                      lights: [
                        ...group.lights,
                        {
                          id: `light-${Date.now()}`,
                          signalId: '',
                          ampelName: nextLightName(current),
                          modelId: 'JS2_3er_mit_FG',
                        },
                      ],
                    }
                  : group,
              ),
            }
          : lane,
      ),
    );
  }

  function deleteLight(laneId: string, signalGroupId: string, lightId: string) {
    setLanes((current) =>
      current.map((lane) =>
        lane.id === laneId
          ? {
              ...lane,
              signalGroups: lane.signalGroups.map((group) =>
                group.id === signalGroupId
                  ? { ...group, lights: group.lights.filter((light) => light.id !== lightId) }
                  : group,
              ),
            }
          : lane,
      ),
    );
  }

  function renderReadonlyTurnDirections(directions: IntersectionWizardTurnDirection[]) {
    return (
      <ToggleButtonGroup
        size="small"
        value={directions}
        sx={{ flexWrap: 'wrap', pointerEvents: 'none', '& .MuiToggleButtonGroup-grouped': { minHeight: 40 } }}
      >
        {turnDirections.map((direction) => {
          const DirectionIcon = turnDirectionIcons[direction];
          const selected = directions.includes(direction);
          return (
            <ToggleButton
              key={direction}
              value={direction}
              aria-label={turnDirectionLabels[direction]}
              title={turnDirectionLabels[direction]}
              sx={{
                px: 1.5,
                color: selected ? 'common.white' : 'text.disabled',
                bgcolor: selected ? (theme) => alpha(theme.palette.primary.main, 0.6) : undefined,
                borderColor: selected ? (theme) => alpha(theme.palette.primary.main, 0.28) : undefined,
                '&.Mui-selected, &.Mui-selected:hover': {
                  color: 'common.white',
                  bgcolor: (theme) => alpha(theme.palette.primary.main, 0.6),
                  borderColor: (theme) => alpha(theme.palette.primary.main, 0.28),
                },
              }}
            >
              <DirectionIcon fontSize="small" />
            </ToggleButton>
          );
        })}
      </ToggleButtonGroup>
    );
  }

  function renderSignalGroupTurnDirections(lane: LaneFixture, group: SignalGroupFixture) {
    return (
      <ToggleButtonGroup
        size="small"
        value={group.turnDirections}
        sx={{ flexWrap: 'wrap', '& .MuiToggleButtonGroup-grouped': { minHeight: 40 } }}
      >
        {turnDirections.map((direction) => {
          const DirectionIcon = turnDirectionIcons[direction];
          const disabled = !lane.turnDirections.includes(direction);
          return (
            <ToggleButton
              key={direction}
              value={direction}
              disabled={disabled}
              aria-label={turnDirectionLabels[direction]}
              title={turnDirectionLabels[direction]}
              onClick={() =>
                updateSignalGroup(lane.id, group.id, {
                  turnDirections: toggleTurnDirection(group.turnDirections, direction).filter((selectedDirection) =>
                    lane.turnDirections.includes(selectedDirection),
                  ),
                })
              }
              sx={{
                px: 1.25,
                color: disabled ? 'text.disabled' : 'grey.900',
                '&.Mui-selected, &.Mui-selected:hover': {
                  color: 'common.white',
                  bgcolor: 'success.main',
                  borderColor: 'success.main',
                },
                '&.Mui-disabled.Mui-selected': {
                  color: 'common.white',
                  bgcolor: 'success.main',
                  borderColor: 'success.main',
                  opacity: 0.65,
                },
              }}
            >
              <DirectionIcon fontSize="small" />
            </ToggleButton>
          );
        })}
      </ToggleButtonGroup>
    );
  }

  function renderLightRow(lane: LaneFixture, group: SignalGroupFixture, light: TrafficLightFixture, readonly: boolean) {
    return (
      <Box
        key={light.id}
        sx={{
          display: 'grid',
          gap: 1.25,
          gridTemplateColumns: { xs: '1fr', md: '5rem 5rem minmax(13rem, 1fr) 2.5rem' },
          alignItems: 'end',
        }}
      >
        <Stack spacing={0.5}>
          <Typography variant="caption" color="text.secondary">
            Signal-ID
          </Typography>
          <TextField
            value={light.signalId}
            disabled={readonly}
            onChange={(event) => updateLight(lane.id, group.id, light.id, { signalId: event.target.value })}
            size="small"
            inputProps={{ maxLength: 4, 'aria-label': `Signal-ID ${light.ampelName}` }}
          />
        </Stack>
        <Stack spacing={0.5}>
          <Typography variant="caption" color="text.secondary">
            Ampelname
          </Typography>
          <TextField
            value={light.ampelName}
            disabled={readonly}
            onChange={(event) => updateLight(lane.id, group.id, light.id, { ampelName: event.target.value })}
            size="small"
            inputProps={{ maxLength: 4, 'aria-label': `Ampelname Signal ${light.signalId}` }}
          />
        </Stack>
        <Stack spacing={0.5}>
          <Typography variant="caption" color="text.secondary">
            Ampelmodell
          </Typography>
          <FormControl size="small" fullWidth disabled={readonly}>
            <Select
              value={light.modelId}
              inputProps={{ 'aria-label': `Ampelmodell Signal ${light.signalId}` }}
              onChange={(event) => updateLight(lane.id, group.id, light.id, { modelId: event.target.value })}
            >
              {knownSignalModels.map((model) => (
                <MenuItem key={model.id} value={model.id} dense>
                  {signalModelLabel(model)}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Stack>
        {readonly ? (
          <Box sx={{ width: 40, height: 40 }} />
        ) : (
          <IconButton
            size="small"
            aria-label={`Ampel ${light.ampelName || light.signalId || light.id} löschen`}
            title="Ampel löschen"
            onClick={() => deleteLight(lane.id, group.id, light.id)}
            sx={{ width: 40, height: 40, color: 'text.secondary', '&:hover': { color: 'error.main' } }}
          >
            <DeleteOutlinedIcon fontSize="small" />
          </IconButton>
        )}
      </Box>
    );
  }

  function renderSimpleSignalGroup(lane: LaneFixture, group: SignalGroupFixture) {
    return (
      <Stack key={group.id} spacing={1.5}>
        <Stack spacing={0.5}>
          <Typography variant="caption" color="text.secondary">
            Ampelgruppe
          </Typography>
          <TextField
            value={group.name}
            onChange={(event) => updateSignalGroup(lane.id, group.id, { name: event.target.value })}
            size="small"
            inputProps={{ maxLength: 24, 'aria-label': `Ampelgruppe ${group.name}` }}
          />
        </Stack>
        <Stack spacing={1}>
          {group.lights.map((light) => renderLightRow(lane, group, light, false))}
          <Button size="small" startIcon={<AddIcon />} onClick={() => addLight(lane.id, group.id)}>
            Ampel hinzufügen
          </Button>
        </Stack>
      </Stack>
    );
  }

  function renderSignalGroupCard(lane: LaneFixture, group: SignalGroupFixture, defaultCard: boolean) {
    return (
      <Paper key={group.id} variant="outlined" sx={{ p: 1.5, borderRadius: 2, bgcolor: '#f3faf4' }}>
        <Stack spacing={1.5}>
          <Stack direction="row" spacing={1} alignItems="center">
            <Typography variant="subtitle2" sx={{ flex: 1 }}>
              {defaultCard ? `Standard-Ampelgruppe: ${group.name}` : `Ampelgruppe: ${group.name}`}
            </Typography>
            {!defaultCard && (
              <IconButton
                size="small"
                aria-label={`Ampelgruppe ${group.name || group.id} löschen`}
                title="Ampelgruppe löschen"
                onClick={() => deleteSignalGroup(lane.id, group.id)}
              >
                <DeleteOutlinedIcon fontSize="small" />
              </IconButton>
            )}
          </Stack>
          <Box
            sx={{
              display: 'grid',
              gap: 1.25,
              gridTemplateColumns: { xs: '1fr', md: 'max-content minmax(14rem, 1fr) max-content' },
              alignItems: 'start',
            }}
          >
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Abbiegerichtungen der Ampelgruppe
              </Typography>
              {renderSignalGroupTurnDirections(lane, group)}
            </Stack>
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Routen
              </Typography>
              <Autocomplete<string, true, false, true>
                multiple
                freeSolo
                size="small"
                options={routeOptions}
                value={group.routeSelection}
                onChange={(_event, routeSelection) => updateSignalGroup(lane.id, group.id, { routeSelection })}
                renderTags={(value, getTagProps) =>
                  value.map((option, index) => (
                    <Chip {...getTagProps({ index })} key={`${option}-${index}`} label={option} size="small" />
                  ))
                }
                renderInput={(params) => <TextField {...params} />}
              />
            </Stack>
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Bei Standard-Freigabe
              </Typography>
              <ToggleButtonGroup
                exclusive
                size="small"
                value={group.mode}
                disabled={group.routeSelection.includes(alwaysRouteLabel)}
                onChange={(_event, mode) => {
                  if (mode) updateSignalGroup(lane.id, group.id, { mode: mode as IntersectionWizardRouteRuleMode });
                }}
                sx={{ '& .MuiToggleButtonGroup-grouped': { minHeight: 40 } }}
              >
                <ToggleButton
                  value="ONLY"
                  title="Fahrzeuge mit diesen Routen warten, wenn die Standard-Ampelgruppe grün anzeigt."
                >
                  Warten
                </ToggleButton>
                <ToggleButton value="ALSO" title="Fahrzeuge fahren auch, wenn die Standard-Ampelgruppe grün anzeigt.">
                  Fahren
                </ToggleButton>
              </ToggleButtonGroup>
            </Stack>
          </Box>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Ampelgruppe
            </Typography>
            <TextField
              value={group.name}
              onChange={(event) => updateSignalGroup(lane.id, group.id, { name: event.target.value })}
              size="small"
              inputProps={{ maxLength: 24, 'aria-label': `Ampelgruppe ${group.name}` }}
            />
          </Stack>
          <Stack spacing={1}>
            {group.lights.map((light) => renderLightRow(lane, group, light, false))}
            <Button size="small" startIcon={<AddIcon />} onClick={() => addLight(lane.id, group.id)}>
              Ampel hinzufügen
            </Button>
          </Stack>
        </Stack>
      </Paper>
    );
  }

  function renderLaneCard(lane: LaneFixture) {
    const hasSignalGroupCards = lane.signalGroups.length > 1;
    const firstGroup = lane.signalGroups[0];
    return (
      <Paper key={lane.id} variant="outlined" sx={{ p: 1.5, borderRadius: 2, bgcolor: 'background.paper' }}>
        <Stack spacing={1.5}>
          <Stack direction="row" spacing={1} alignItems="center">
            <Typography variant="h5" sx={{ flex: 1 }}>
              Ampelgruppen für {lane.name}
            </Typography>
            <Button size="small" startIcon={<AddIcon />} onClick={() => addSignalGroup(lane.id)}>
              Richtungsampel hinzufügen
            </Button>
          </Stack>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Abbiegerichtungen der Fahrspur
            </Typography>
            {renderReadonlyTurnDirections(lane.turnDirections)}
          </Stack>
          {hasSignalGroupCards && firstGroup && (
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Fahrspur-Ampel
              </Typography>
              {renderLightRow(lane, firstGroup, lane.laneSignal, true)}
            </Stack>
          )}
          {hasSignalGroupCards ? (
            <Stack spacing={1.25}>
              {lane.signalGroups.map((group, index) => renderSignalGroupCard(lane, group, index === 0))}
            </Stack>
          ) : firstGroup ? (
            renderSimpleSignalGroup(lane, firstGroup)
          ) : (
            <Typography variant="body2" color="text.secondary">
              Keine Ampelgruppe angelegt.
            </Typography>
          )}
        </Stack>
      </Paper>
    );
  }

  const lanesByApproach = Object.entries(
    lanes.reduce(
      (result, lane) => ({
        ...result,
        [lane.approach]: [...(result[lane.approach] ?? []), lane],
      }),
      {} as Partial<Record<IntersectionWizardApproach, LaneFixture[]>>,
    ),
  ) as [IntersectionWizardApproach, LaneFixture[]][];

  return (
    <Stack spacing={2} sx={{ maxWidth: 1280 }}>
      {lanesByApproach.map(([approach, approachLanes]) => {
        const ApproachIcon = approachIcons[approach];
        return (
          <Paper
            key={approach}
            variant="outlined"
            sx={{ p: 2, borderRadius: 2, bgcolor: approachBackgrounds[approach] }}
          >
            <Stack spacing={1.5}>
              <Stack direction="row" spacing={1} alignItems="center">
                <ApproachIcon fontSize="small" />
                <Typography variant="h6">{approachLabels[approach]}</Typography>
              </Stack>
              <Stack spacing={1}>{approachLanes.map((lane) => renderLaneCard(lane))}</Stack>
            </Stack>
          </Paper>
        );
      })}
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Traffic Light Definition Step',
  component: TrafficLightDefinitionPrototype,
} satisfies Meta<typeof TrafficLightDefinitionPrototype>;

export default meta;
type Story = StoryObj<typeof meta>;

export const CurrentCards: Story = {};
