import { useState } from 'react';
import Box from '@mui/material/Box';
import Checkbox from '@mui/material/Checkbox';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import ListItemText from '@mui/material/ListItemText';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import type { IntersectionWizardTurnDirection, TrafficLightModelAppDto } from '@ce/web-shared';

type LaneSignalFixture = {
  id: string;
  laneName: string;
  signalId: number;
  ampelName: string;
  modelId: string;
  availableTurnDirections: IntersectionWizardTurnDirection[];
  turnDirections: IntersectionWizardTurnDirection[];
};

const turnDirectionLabels: Record<IntersectionWizardTurnDirection, string> = {
  LEFT: 'Links',
  HALF_LEFT: 'Halblinks',
  STRAIGHT: 'Geradeaus',
  HALF_RIGHT: 'Halbrechts',
  RIGHT: 'Rechts',
};

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
  {
    id: 'NONE',
    name: 'NO SIGNAL MODEL',
    type: 'LIGHT_STRUCTURE',
    luaConstant: 'NONE',
    positionRed: 0,
    positionGreen: 0,
    positionYellow: 0,
    positionRedYellow: 0,
    positionPedestrians: 0,
    positionOff: 0,
    positionOffBlinking: 0,
  },
];

const initialLaneSignals: LaneSignalFixture[] = [
  {
    id: 'lane-1',
    laneName: 'Lane 1',
    signalId: 92,
    ampelName: 'K1',
    modelId: 'JS2_3er_mit_FG',
    availableTurnDirections: ['STRAIGHT'],
    turnDirections: ['STRAIGHT'],
  },
  {
    id: 'lane-2',
    laneName: 'Lane 2',
    signalId: 91,
    ampelName: 'K2',
    modelId: 'JS2_3er_mit_FG',
    availableTurnDirections: ['LEFT'],
    turnDirections: ['LEFT'],
  },
  {
    id: 'lane-3',
    laneName: 'Lane 3',
    signalId: 96,
    ampelName: 'K3',
    modelId: 'JS2_3er_mit_FG',
    availableTurnDirections: ['LEFT', 'STRAIGHT'],
    turnDirections: ['STRAIGHT'],
  },
  {
    id: 'lane-4',
    laneName: 'Lane 4',
    signalId: 89,
    ampelName: 'K4',
    modelId: 'Unsichtbar_2er',
    availableTurnDirections: ['STRAIGHT', 'RIGHT'],
    turnDirections: ['RIGHT'],
  },
  {
    id: 'lane-5',
    laneName: 'Lane 5',
    signalId: 88,
    ampelName: 'S1',
    modelId: 'MA1_STRAB_3er_2_gruen',
    availableTurnDirections: ['LEFT', 'STRAIGHT'],
    turnDirections: ['LEFT'],
  },
];

function signalModelLabel(model: TrafficLightModelAppDto): string {
  return model.luaConstant ?? model.name;
}

function IntersectionLaneSignalModelStepPrototype() {
  const [laneSignals, setLaneSignals] = useState(initialLaneSignals);

  function updateLaneSignal(id: string, patch: Partial<LaneSignalFixture>) {
    setLaneSignals((current) =>
      current.map((laneSignal) => (laneSignal.id === id ? { ...laneSignal, ...patch } : laneSignal)),
    );
  }

  return (
    <Stack spacing={2} sx={{ maxWidth: 980 }}>
      <Paper variant="outlined">
        <Stack
          direction="row"
          spacing={1.5}
          sx={{
            display: { xs: 'none', md: 'flex' },
            px: 2,
            py: 1,
            borderBottom: '1px solid',
            borderColor: 'divider',
          }}
        >
          <Typography variant="caption" color="text.secondary" sx={{ width: 190 }}>
            Fahrspur-Signal
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: 72 }}>
            Name
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ width: 220 }}>
            Steuert
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ flex: 1 }}>
            Signalmodell
          </Typography>
        </Stack>
        <Stack divider={<Box sx={{ borderBottom: '1px solid', borderColor: 'divider' }} />}>
          {laneSignals.map((laneSignal) => (
            <Stack
              key={laneSignal.id}
              direction={{ xs: 'column', md: 'row' }}
              spacing={1.5}
              alignItems={{ md: 'center' }}
              sx={{ px: 2, py: 1.25 }}
            >
              <Stack spacing={0.5} sx={{ width: { xs: 1, md: 190 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { md: 'none' } }}>
                  Fahrspur-Signal
                </Typography>
                <Typography variant="body2" fontWeight={700}>
                  Signal {laneSignal.signalId} ({laneSignal.laneName})
                </Typography>
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, md: 72 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { md: 'none' } }}>
                  Name
                </Typography>
                <TextField
                  value={laneSignal.ampelName}
                  onChange={(event) => updateLaneSignal(laneSignal.id, { ampelName: event.target.value })}
                  size="small"
                  fullWidth
                  inputProps={{ 'aria-label': `Name fuer Signal ${laneSignal.signalId}`, maxLength: 4 }}
                />
              </Stack>
              <Stack spacing={0.5} sx={{ width: { xs: 1, md: 220 } }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { md: 'none' } }}>
                  Steuert
                </Typography>
                <FormControl size="small" fullWidth>
                  <InputLabel id={`${laneSignal.id}-turn-directions-label`} size="small">
                    Steuert
                  </InputLabel>
                  <Select
                    multiple
                    labelId={`${laneSignal.id}-turn-directions-label`}
                    label="Steuert"
                    size="small"
                    value={laneSignal.turnDirections}
                    renderValue={(selected) => selected.map((direction) => turnDirectionLabels[direction]).join(', ')}
                    onChange={(event) =>
                      updateLaneSignal(laneSignal.id, {
                        turnDirections: event.target.value as IntersectionWizardTurnDirection[],
                      })
                    }
                  >
                    {laneSignal.availableTurnDirections.map((direction) => (
                      <MenuItem key={direction} value={direction} dense>
                        <Checkbox size="small" checked={laneSignal.turnDirections.includes(direction)} />
                        <ListItemText primary={turnDirectionLabels[direction]} />
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Stack>
              <Stack spacing={0.5} sx={{ flex: 1, minWidth: 0 }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: { md: 'none' } }}>
                  Signalmodell
                </Typography>
                <FormControl size="small" fullWidth>
                  <InputLabel id={`${laneSignal.id}-model-label`} size="small">
                    Signalmodell
                  </InputLabel>
                  <Select
                    labelId={`${laneSignal.id}-model-label`}
                    label="Signalmodell"
                    size="small"
                    value={laneSignal.modelId}
                    onChange={(event) => updateLaneSignal(laneSignal.id, { modelId: event.target.value })}
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
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Lane Signal Model Step',
  component: IntersectionLaneSignalModelStepPrototype,
} satisfies Meta<typeof IntersectionLaneSignalModelStepPrototype>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AlternativeStep4: Story = {};
