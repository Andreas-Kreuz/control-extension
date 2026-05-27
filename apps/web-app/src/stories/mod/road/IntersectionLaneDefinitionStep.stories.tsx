import { useState } from 'react';
import Box from '@mui/material/Box';
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
  IntersectionWizardTurnDirection,
  TrafficLightModelAppDto,
} from '@ce/web-shared';

type LaneFixture = {
  id: string;
  name: string;
  approach: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
  laneSignalId: string;
  laneSignalName: string;
  signalModelId: string;
};

const approaches: IntersectionWizardApproach[] = [
  'NORTH',
  'NORTH_EAST',
  'EAST',
  'SOUTH_EAST',
  'SOUTH',
  'SOUTH_WEST',
  'WEST',
  'NORTH_WEST',
];

const turnDirections: IntersectionWizardTurnDirection[] = ['LEFT', 'HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT', 'RIGHT'];

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
    modelNamePatterns: [],
    modelNameMatchOrder: 0,
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
    modelNamePatterns: [],
    modelNameMatchOrder: 0,
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
    modelNamePatterns: [],
    modelNameMatchOrder: 0,
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
    modelNamePatterns: [],
    modelNameMatchOrder: 0,
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
    id: 'lane-1',
    name: 'Spur 1',
    approach: 'NORTH',
    turnDirections: ['STRAIGHT'],
    laneSignalId: '92',
    laneSignalName: 'K1',
    signalModelId: 'JS2_3er_mit_FG',
  },
  {
    id: 'lane-2',
    name: 'Spur 2',
    approach: 'EAST',
    turnDirections: ['LEFT', 'STRAIGHT'],
    laneSignalId: '91',
    laneSignalName: 'K2',
    signalModelId: 'JS2_3er_mit_FG',
  },
  {
    id: 'lane-3',
    name: 'Spur 3',
    approach: 'SOUTH_WEST',
    turnDirections: ['RIGHT'],
    laneSignalId: '89',
    laneSignalName: 'K3',
    signalModelId: 'Unsichtbar_2er',
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

function IntersectionLaneDefinitionStepPrototype() {
  const [lanes, setLanes] = useState(initialLanes);

  function updateLane(id: string, patch: Partial<LaneFixture>) {
    setLanes((current) => current.map((lane) => (lane.id === id ? { ...lane, ...patch } : lane)));
  }

  function deleteLane(id: string) {
    setLanes((current) => current.filter((lane) => lane.id !== id));
  }

  function renderDeleteButton(lane: LaneFixture) {
    return (
      <IconButton
        size="small"
        aria-label={`${lane.name} entfernen`}
        title={`${lane.name} entfernen`}
        onClick={() => deleteLane(lane.id)}
        sx={{
          width: 40,
          height: 40,
          color: 'text.secondary',
          '&:hover': {
            color: 'error.main',
            bgcolor: 'error.light',
          },
        }}
      >
        <DeleteOutlinedIcon fontSize="small" />
      </IconButton>
    );
  }

  function renderLaneNameField(lane: LaneFixture) {
    return (
      <TextField
        value={lane.name}
        onChange={(event) => updateLane(lane.id, { name: event.target.value })}
        size="small"
        fullWidth
        inputProps={{ maxLength: 10, 'aria-label': `Fahrspur-Name ${lane.name}` }}
      />
    );
  }

  function renderApproachSelect(lane: LaneFixture) {
    return (
      <FormControl size="small" fullWidth>
        <Select
          size="small"
          value={lane.approach}
          inputProps={{ 'aria-label': `Zufahrt aus ${lane.name}` }}
          onChange={(event) => updateLane(lane.id, { approach: event.target.value as IntersectionWizardApproach })}
        >
          {approaches.map((approach) => {
            const ApproachIcon = approachIcons[approach];
            return (
              <MenuItem key={approach} value={approach} dense>
                <Stack direction="row" spacing={1} alignItems="center">
                  <ApproachIcon fontSize="small" />
                  <span>{approachLabels[approach]}</span>
                </Stack>
              </MenuItem>
            );
          })}
        </Select>
      </FormControl>
    );
  }

  function renderTurnDirectionButtons(lane: LaneFixture) {
    return (
      <ToggleButtonGroup color="success" value={lane.turnDirections} size="small" sx={{ flexWrap: 'wrap' }}>
        {turnDirections.map((turnDirection) => {
          const TurnDirectionIcon = turnDirectionIcons[turnDirection];
          return (
            <ToggleButton
              key={turnDirection}
              value={turnDirection}
              aria-label={turnDirectionLabels[turnDirection]}
              title={turnDirectionLabels[turnDirection]}
              onClick={() =>
                updateLane(lane.id, {
                  turnDirections: toggleTurnDirection(lane.turnDirections, turnDirection),
                })
              }
              sx={{
                px: 1.25,
                color: 'grey.900',
                '&.Mui-selected, &.Mui-selected:hover': {
                  color: 'common.white',
                  bgcolor: 'success.main',
                  borderColor: 'success.main',
                },
              }}
            >
              <TurnDirectionIcon fontSize="small" />
            </ToggleButton>
          );
        })}
      </ToggleButtonGroup>
    );
  }

  function renderSignalIdField(lane: LaneFixture) {
    return (
      <TextField
        value={lane.laneSignalId}
        onChange={(event) => updateLane(lane.id, { laneSignalId: event.target.value })}
        size="small"
        fullWidth
        inputProps={{ inputMode: 'numeric', maxLength: 4, 'aria-label': `Signal-ID ${lane.name}` }}
      />
    );
  }

  function renderSignalNameField(lane: LaneFixture) {
    return (
      <TextField
        value={lane.laneSignalName}
        onChange={(event) => updateLane(lane.id, { laneSignalName: event.target.value })}
        size="small"
        fullWidth
        inputProps={{ maxLength: 4, 'aria-label': `Ampelname ${lane.name}` }}
      />
    );
  }

  function renderSignalModelSelect(lane: LaneFixture) {
    return (
      <FormControl size="small" sx={{ width: 'max-content' }}>
        <Select
          size="small"
          value={lane.signalModelId}
          sx={{ width: 'max-content' }}
          inputProps={{ 'aria-label': `Ampelmodell ${lane.name}` }}
          onChange={(event) => updateLane(lane.id, { signalModelId: event.target.value })}
        >
          {knownSignalModels.map((model) => (
            <MenuItem key={model.id} value={model.id} dense>
              {signalModelLabel(model)}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
    );
  }

  return (
    <Stack spacing={2} sx={{ maxWidth: 1480 }}>
      <Paper variant="outlined">
        <Stack
          direction="row"
          spacing={1.5}
          sx={{
            display: { xs: 'none', lg: 'flex' },
            px: 2,
            py: 1,
            borderBottom: '1px solid',
            borderColor: 'divider',
          }}
        >
          <Typography variant="caption" color="text.secondary" sx={{ width: 124 }}>
            Fahrspur-Name
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: '8rem' }}>
            Zufahrt aus
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ flex: 1 }}>
            Abbiegerichtung
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: 72 }}>
            Signal-ID
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: 72 }}>
            Ampelname
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: 250 }}>
            Ampelmodell
          </Typography>
        </Stack>
        <Stack divider={<Box sx={{ borderBottom: '1px solid', borderColor: 'divider' }} />}>
          {lanes.map((lane) => (
            <Stack
              key={lane.id}
              direction={{ xs: 'column', lg: 'row' }}
              spacing={1.5}
              alignItems={{ lg: 'center' }}
              sx={{ px: 2, py: 1.25 }}
            >
              <Stack spacing={0.5} sx={{ width: { xs: 1, lg: 124 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Fahrspur-Name
                </Typography>
                <TextField
                  value={lane.name}
                  onChange={(event) => updateLane(lane.id, { name: event.target.value })}
                  size="small"
                  fullWidth
                  inputProps={{ maxLength: 10, 'aria-label': `Name ${lane.name}` }}
                />
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, lg: '8rem' } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Zufahrt aus
                </Typography>
                <FormControl size="small" sx={{ width: { xs: 1, lg: '8rem' } }}>
                  <Select
                    size="small"
                    value={lane.approach}
                    inputProps={{ 'aria-label': `Zufahrt aus ${lane.name}` }}
                    onChange={(event) =>
                      updateLane(lane.id, { approach: event.target.value as IntersectionWizardApproach })
                    }
                  >
                    {approaches.map((approach) => {
                      const ApproachIcon = approachIcons[approach];
                      return (
                        <MenuItem key={approach} value={approach} dense>
                          <Stack direction="row" spacing={1} alignItems="center">
                            <ApproachIcon fontSize="small" />
                            <span>{approachLabels[approach]}</span>
                          </Stack>
                        </MenuItem>
                      );
                    })}
                  </Select>
                </FormControl>
              </Stack>
              <Stack spacing={0.5} sx={{ flex: 1, minWidth: 0 }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Abbiegerichtung
                </Typography>
                <ToggleButtonGroup color="success" value={lane.turnDirections} size="small" sx={{ flexWrap: 'wrap' }}>
                  {turnDirections.map((turnDirection) => {
                    const TurnDirectionIcon = turnDirectionIcons[turnDirection];
                    return (
                      <ToggleButton
                        key={turnDirection}
                        value={turnDirection}
                        aria-label={turnDirectionLabels[turnDirection]}
                        title={turnDirectionLabels[turnDirection]}
                        onClick={() =>
                          updateLane(lane.id, {
                            turnDirections: toggleTurnDirection(lane.turnDirections, turnDirection),
                          })
                        }
                        sx={{
                          px: 1.25,
                          color: 'grey.900',
                          '&.Mui-selected, &.Mui-selected:hover': {
                            color: 'common.white',
                            bgcolor: 'success.main',
                            borderColor: 'success.main',
                          },
                        }}
                      >
                        <TurnDirectionIcon fontSize="small" />
                      </ToggleButton>
                    );
                  })}
                </ToggleButtonGroup>
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, lg: 72 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Signal-ID
                </Typography>
                <TextField
                  value={lane.laneSignalId}
                  onChange={(event) => updateLane(lane.id, { laneSignalId: event.target.value })}
                  size="small"
                  fullWidth
                  inputProps={{ inputMode: 'numeric', maxLength: 4, 'aria-label': `Lane Signal ID ${lane.name}` }}
                />
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, lg: 72 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Ampelname
                </Typography>
                <TextField
                  value={lane.laneSignalName}
                  onChange={(event) => updateLane(lane.id, { laneSignalName: event.target.value })}
                  size="small"
                  fullWidth
                  inputProps={{ maxLength: 4, 'aria-label': `Lane Signal Name ${lane.name}` }}
                />
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, lg: 250 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { lg: 'none' } }}>
                  Ampelmodell
                </Typography>
                <FormControl size="small" fullWidth>
                  <Select
                    size="small"
                    value={lane.signalModelId}
                    inputProps={{ 'aria-label': `Ampelmodell ${lane.name}` }}
                    onChange={(event) => updateLane(lane.id, { signalModelId: event.target.value })}
                  >
                    {knownSignalModels.map((model) => (
                      <MenuItem key={model.id} value={model.id} dense>
                        {signalModelLabel(model)}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Stack>
            </Stack>
          ))}
        </Stack>
      </Paper>
      <Stack spacing={1.25}>
        <Typography variant="subtitle2">Kartenlayout</Typography>
        <Stack spacing={1.5}>
          {lanes.map((lane) => (
            <Paper
              key={`${lane.id}-card`}
              variant="outlined"
              sx={{
                p: 1.5,
                position: 'relative',
                containerType: 'inline-size',
                '& .lane-card-grid': {
                  display: 'grid',
                  gap: 2,
                  gridTemplateColumns: '1fr',
                  pr: 5,
                },
                '& .lane-section-title': {
                  display: 'none',
                },
                '& .lane-section-row': {
                  display: 'grid',
                  gap: 1.25,
                  gridTemplateColumns: '1fr',
                  alignItems: 'end',
                },
                '& .lane-name-field': {
                  width: 1,
                },
                '& .lane-heading-field': {
                  width: 1,
                },
                '& .lane-turn-field': {
                  minWidth: 0,
                  alignSelf: 'start',
                },
                '& .signal-id-field': {
                  width: 1,
                },
                '& .signal-name-field': {
                  width: 1,
                },
                '& .signal-model-field': {
                  minWidth: 0,
                },
                '@container (min-width: 36rem)': {
                  '& .lane-card-grid': {
                    gap: 2.5,
                  },
                  '& .lane-section-title': {
                    display: 'block',
                  },
                  '& .lane-section-row': {
                    gridTemplateColumns: '10rem 8rem minmax(15rem, 1fr)',
                  },
                  '& .signal-section-row': {
                    gridTemplateColumns: '4.5rem 4.5rem minmax(14rem, 1fr)',
                  },
                },
                '@container (min-width: 76rem)': {
                  '& .lane-card-grid': {
                    gridTemplateColumns: 'minmax(0, 1.2fr) minmax(0, 1fr)',
                    alignItems: 'start',
                  },
                },
              }}
            >
              <Box sx={{ position: 'absolute', top: 8, right: 8 }}>{renderDeleteButton(lane)}</Box>
              <Box className="lane-card-grid">
                <Stack spacing={1.25} sx={{ flex: 1.2, minWidth: 0 }}>
                  <Typography className="lane-section-title" variant="subtitle2">
                    Fahrspur
                  </Typography>
                  <Box className="lane-section-row">
                    <Stack className="lane-name-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Fahrspur-Name
                      </Typography>
                      <TextField
                        value={lane.name}
                        onChange={(event) => updateLane(lane.id, { name: event.target.value })}
                        size="small"
                        fullWidth
                        inputProps={{ maxLength: 10, 'aria-label': `Fahrspur-Name ${lane.name}` }}
                      />
                    </Stack>
                    <Stack className="lane-heading-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Zufahrt aus
                      </Typography>
                      <FormControl size="small" fullWidth>
                        <Select
                          size="small"
                          value={lane.approach}
                          inputProps={{ 'aria-label': `Zufahrt aus ${lane.name}` }}
                          onChange={(event) =>
                            updateLane(lane.id, { approach: event.target.value as IntersectionWizardApproach })
                          }
                        >
                          {approaches.map((approach) => {
                            const ApproachIcon = approachIcons[approach];
                            return (
                              <MenuItem key={approach} value={approach} dense>
                                <Stack direction="row" spacing={1} alignItems="center">
                                  <ApproachIcon fontSize="small" />
                                  <span>{approachLabels[approach]}</span>
                                </Stack>
                              </MenuItem>
                            );
                          })}
                        </Select>
                      </FormControl>
                    </Stack>
                    <Stack className="lane-turn-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Abbiegerichtung
                      </Typography>
                      <ToggleButtonGroup
                        color="success"
                        value={lane.turnDirections}
                        size="small"
                        sx={{
                          flexWrap: 'wrap',
                          '& .MuiToggleButtonGroup-grouped': {
                            minHeight: 40,
                          },
                        }}
                      >
                        {turnDirections.map((turnDirection) => {
                          const TurnDirectionIcon = turnDirectionIcons[turnDirection];
                          return (
                            <ToggleButton
                              key={turnDirection}
                              value={turnDirection}
                              aria-label={turnDirectionLabels[turnDirection]}
                              title={turnDirectionLabels[turnDirection]}
                              onClick={() =>
                                updateLane(lane.id, {
                                  turnDirections: toggleTurnDirection(lane.turnDirections, turnDirection),
                                })
                              }
                              sx={{
                                px: 1.25,
                                color: 'grey.900',
                                '&.Mui-selected, &.Mui-selected:hover': {
                                  color: 'common.white',
                                  bgcolor: 'success.main',
                                  borderColor: 'success.main',
                                },
                              }}
                            >
                              <TurnDirectionIcon fontSize="small" />
                            </ToggleButton>
                          );
                        })}
                      </ToggleButtonGroup>
                    </Stack>
                  </Box>
                </Stack>
                <Stack spacing={1.25} sx={{ flex: 1, minWidth: 0 }}>
                  <Typography className="lane-section-title" variant="subtitle2">
                    Fahrspur-Ampel
                  </Typography>
                  <Box className="lane-section-row signal-section-row">
                    <Stack className="signal-id-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Signal-ID
                      </Typography>
                      <TextField
                        value={lane.laneSignalId}
                        onChange={(event) => updateLane(lane.id, { laneSignalId: event.target.value })}
                        size="small"
                        fullWidth
                        inputProps={{ inputMode: 'numeric', maxLength: 4, 'aria-label': `Signal-ID ${lane.name}` }}
                      />
                    </Stack>
                    <Stack className="signal-name-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Ampelname
                      </Typography>
                      <TextField
                        value={lane.laneSignalName}
                        onChange={(event) => updateLane(lane.id, { laneSignalName: event.target.value })}
                        size="small"
                        fullWidth
                        inputProps={{ maxLength: 4, 'aria-label': `Ampelname ${lane.name}` }}
                      />
                    </Stack>
                    <Stack className="signal-model-field" spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Ampelmodell
                      </Typography>
                      <FormControl size="small" fullWidth>
                        <Select
                          size="small"
                          value={lane.signalModelId}
                          inputProps={{ 'aria-label': `Ampelmodell ${lane.name}` }}
                          onChange={(event) => updateLane(lane.id, { signalModelId: event.target.value })}
                        >
                          {knownSignalModels.map((model) => (
                            <MenuItem key={model.id} value={model.id} dense>
                              {signalModelLabel(model)}
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>
                    </Stack>
                  </Box>
                </Stack>
              </Box>
            </Paper>
          ))}
        </Stack>
      </Stack>
      <Stack spacing={1.25}>
        <Typography variant="subtitle2">Variante 1: Zwei Arbeitszeilen</Typography>
        <Stack spacing={1.5}>
          {lanes.map((lane) => (
            <Paper
              key={`${lane.id}-two-lines`}
              variant="outlined"
              sx={{
                p: 1.5,
                containerType: 'inline-size',
                '& .two-line-card': {
                  display: 'grid',
                  gap: 1.25,
                  gridTemplateColumns: '1fr max-content',
                },
                '& .two-line-row': {
                  display: 'grid',
                  gap: 1.25,
                  gridTemplateColumns: '1fr',
                  alignItems: 'end',
                },
                '@container (min-width: 29rem)': {
                  '& .lane-row': {
                    gridTemplateColumns: '10rem 8rem max-content',
                  },
                  '& .signal-row': {
                    gridTemplateColumns: '4.5rem 4.5rem max-content',
                  },
                },
              }}
            >
              <Box className="two-line-card">
                <Stack spacing={1.5} sx={{ minWidth: 0 }}>
                  <Box className="two-line-row lane-row">
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Fahrspur-Name
                      </Typography>
                      {renderLaneNameField(lane)}
                    </Stack>
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Zufahrt aus
                      </Typography>
                      {renderApproachSelect(lane)}
                    </Stack>
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Abbiegerichtung
                      </Typography>
                      {renderTurnDirectionButtons(lane)}
                    </Stack>
                  </Box>
                  <Box className="two-line-row signal-row">
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Signal-ID
                      </Typography>
                      {renderSignalIdField(lane)}
                    </Stack>
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Ampelname
                      </Typography>
                      {renderSignalNameField(lane)}
                    </Stack>
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Ampelmodell
                      </Typography>
                      {renderSignalModelSelect(lane)}
                    </Stack>
                  </Box>
                </Stack>
                {renderDeleteButton(lane)}
              </Box>
            </Paper>
          ))}
        </Stack>
      </Stack>
      <Stack spacing={1.25}>
        <Typography variant="subtitle2">Variante 2: Fahrspur-Leiste</Typography>
        <Stack spacing={1.5}>
          {lanes.map((lane) => {
            const ApproachIcon = approachIcons[lane.approach];
            return (
              <Paper
                key={`${lane.id}-rail`}
                variant="outlined"
                sx={{
                  p: 1.5,
                  containerType: 'inline-size',
                  '& .rail-card': {
                    display: 'grid',
                    gap: 1.5,
                    gridTemplateColumns: '1fr max-content',
                    alignItems: 'start',
                  },
                  '& .rail-body': {
                    display: 'grid',
                    gap: 1.5,
                    gridTemplateColumns: '1fr',
                  },
                  '& .rail-fields': {
                    display: 'grid',
                    gap: 1.25,
                    gridTemplateColumns: '1fr',
                    alignItems: 'end',
                  },
                  '@container (min-width: 42rem)': {
                    '& .rail-card': {
                      gridTemplateColumns: '9rem 1fr max-content',
                    },
                    '& .rail-summary': {
                      display: 'block',
                    },
                    '& .rail-fields': {
                      gridTemplateColumns: '10rem 8rem max-content',
                    },
                    '& .rail-signal-fields': {
                      gridTemplateColumns: '4.5rem 4.5rem max-content',
                    },
                  },
                }}
              >
                <Box className="rail-card">
                  <Stack className="rail-summary" spacing={0.75} sx={{ display: 'none' }}>
                    <Typography variant="subtitle2">{lane.name}</Typography>
                    <Stack direction="row" spacing={0.75} alignItems="center" color="text.secondary">
                      <ApproachIcon fontSize="small" />
                      <Typography variant="caption">{approachLabels[lane.approach]}</Typography>
                    </Stack>
                    <Typography variant="caption" color="text.secondary">
                      Signal {lane.laneSignalId}
                    </Typography>
                  </Stack>
                  <Stack className="rail-body">
                    <Box className="rail-fields">
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Fahrspur-Name
                        </Typography>
                        {renderLaneNameField(lane)}
                      </Stack>
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Zufahrt aus
                        </Typography>
                        {renderApproachSelect(lane)}
                      </Stack>
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Abbiegerichtung
                        </Typography>
                        {renderTurnDirectionButtons(lane)}
                      </Stack>
                    </Box>
                    <Box className="rail-fields rail-signal-fields">
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Signal-ID
                        </Typography>
                        {renderSignalIdField(lane)}
                      </Stack>
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Ampelname
                        </Typography>
                        {renderSignalNameField(lane)}
                      </Stack>
                      <Stack spacing={0.5}>
                        <Typography variant="caption" color="text.secondary">
                          Ampelmodell
                        </Typography>
                        {renderSignalModelSelect(lane)}
                      </Stack>
                    </Box>
                  </Stack>
                  {renderDeleteButton(lane)}
                </Box>
              </Paper>
            );
          })}
        </Stack>
      </Stack>
      <Stack spacing={1.25}>
        <Typography variant="subtitle2">Variante 3: Kompaktes Datenblatt</Typography>
        <Paper variant="outlined">
          <Stack divider={<Box sx={{ borderBottom: '1px solid', borderColor: 'divider' }} />}>
            {lanes.map((lane) => (
              <Box
                key={`${lane.id}-sheet`}
                sx={{
                  p: 1.25,
                  containerType: 'inline-size',
                  display: 'grid',
                  gap: 1.25,
                  gridTemplateColumns: '1fr max-content',
                  alignItems: 'end',
                  '& .sheet-fields': {
                    display: 'grid',
                    gap: 1.25,
                    gridTemplateColumns: '1fr',
                    alignItems: 'end',
                  },
                  '@container (min-width: 52rem)': {
                    '& .sheet-fields': {
                      gridTemplateColumns: '10rem 8rem max-content 4.5rem 4.5rem max-content',
                    },
                  },
                }}
              >
                <Box className="sheet-fields">
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Fahrspur-Name
                    </Typography>
                    {renderLaneNameField(lane)}
                  </Stack>
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Zufahrt aus
                    </Typography>
                    {renderApproachSelect(lane)}
                  </Stack>
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Abbiegerichtung
                    </Typography>
                    {renderTurnDirectionButtons(lane)}
                  </Stack>
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Signal-ID
                    </Typography>
                    {renderSignalIdField(lane)}
                  </Stack>
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Ampelname
                    </Typography>
                    {renderSignalNameField(lane)}
                  </Stack>
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Ampelmodell
                    </Typography>
                    {renderSignalModelSelect(lane)}
                  </Stack>
                </Box>
                {renderDeleteButton(lane)}
              </Box>
            ))}
          </Stack>
        </Paper>
      </Stack>
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Lane Definition Step',
  component: IntersectionLaneDefinitionStepPrototype,
} satisfies Meta<typeof IntersectionLaneDefinitionStepPrototype>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AlternativeStep3: Story = {};
