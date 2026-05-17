import { useMemo, useState } from 'react';
import type { DragEvent } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import StraightIcon from '@mui/icons-material/Straight';
import TurnLeftIcon from '@mui/icons-material/TurnLeft';
import TurnRightIcon from '@mui/icons-material/TurnRight';
import type { Meta, StoryObj } from '@storybook/react';

type DirectionFixture = 'LEFT' | 'STRAIGHT' | 'RIGHT';

type LaneFixture = {
  id: string;
  name: string;
  signalId: number;
  directions: DirectionFixture[];
};

type SignalGroupFixture = {
  id: string;
  name: string;
  tone: string;
};

type AssignmentFixture = {
  id: string;
  laneId: string;
  signalGroupId: string;
  routeName: string;
};

const lanes: LaneFixture[] = [
  { id: 'lane-1', name: 'Spur 1', signalId: 92, directions: ['STRAIGHT'] },
  { id: 'lane-2', name: 'Spur 2', signalId: 91, directions: ['LEFT'] },
  { id: 'lane-3', name: 'Spur 3', signalId: 96, directions: ['STRAIGHT'] },
  { id: 'lane-4', name: 'Spur 4', signalId: 89, directions: ['STRAIGHT', 'RIGHT'] },
  { id: 'lane-5', name: 'Spur 5', signalId: 88, directions: ['LEFT'] },
  { id: 'lane-5a', name: 'Spur 5a', signalId: 86, directions: ['LEFT'] },
  { id: 'lane-6', name: 'Spur 6', signalId: 85, directions: ['RIGHT'] },
  { id: 'lane-7', name: 'Spur 7', signalId: 83, directions: ['STRAIGHT'] },
  { id: 'lane-8', name: 'Spur 8', signalId: 93, directions: ['LEFT', 'STRAIGHT'] },
  { id: 'lane-10', name: 'Spur 10', signalId: 80, directions: ['LEFT', 'STRAIGHT', 'RIGHT'] },
  { id: 'lane-11', name: 'Spur 11', signalId: 95, directions: ['RIGHT'] },
];

const signalGroups: SignalGroupFixture[] = [
  { id: 'sg-lane-1-straight', name: 'sgLane1Straight', tone: '#e8f3ff' },
  { id: 'sg-lane-2-left', name: 'sgLane2Left', tone: '#eef9ef' },
  { id: 'sg-lane-3-straight', name: 'sgLane3Straight', tone: '#fff5e8' },
  { id: 'sg-lane-4-straight', name: 'sgLane4Straight', tone: '#f5edff' },
  { id: 'sg-lane-4-right', name: 'sgLane4Right', tone: '#eef7f5' },
  { id: 'sg-lane-5-and-5a-left', name: 'sgLane5and5aLeft', tone: '#fff0f0' },
  { id: 'sg-lane-6-right', name: 'sgLane6Right', tone: '#f2f5ff' },
  { id: 'sg-lane-7-straight', name: 'sgLane7Straight', tone: '#f7f3e8' },
  { id: 'sg-lane-8-straight', name: 'sgLane8Straight', tone: '#eaf5eb' },
  { id: 'sg-lane-8-left', name: 'sgLane8Left', tone: '#f7edf6' },
  { id: 'sg-lane-10-all-directions', name: 'sgLane10AllDirections', tone: '#edf6fb' },
  { id: 'sg-lane-11-right', name: 'sgLane11Right', tone: '#f3f0e8' },
  { id: 'sg-ped-north-south', name: 'sgPedNorthSouth', tone: '#f6f6f6' },
  { id: 'sg-ped-east-west', name: 'sgPedEastWest', tone: '#f6f6f6' },
  { id: 'sg-ped-west-east', name: 'sgPedWestEast', tone: '#f6f6f6' },
  { id: 'sg-ped-south-north', name: 'sgPedSouthNorth', tone: '#f6f6f6' },
];

const routeNames = ['', 'Tram 11 Heiderand', 'Tram 11 Rehfeld'];
const directionIcons = {
  LEFT: TurnLeftIcon,
  STRAIGHT: StraightIcon,
  RIGHT: TurnRightIcon,
} satisfies Record<DirectionFixture, typeof TurnLeftIcon>;

const initialAssignments: AssignmentFixture[] = [
  { id: 'assignment-1', laneId: 'lane-1', signalGroupId: 'sg-lane-1-straight', routeName: '' },
  { id: 'assignment-2', laneId: 'lane-2', signalGroupId: 'sg-lane-2-left', routeName: '' },
  { id: 'assignment-3', laneId: 'lane-3', signalGroupId: 'sg-lane-3-straight', routeName: '' },
  { id: 'assignment-4', laneId: 'lane-4', signalGroupId: 'sg-lane-4-straight', routeName: '' },
  { id: 'assignment-5', laneId: 'lane-4', signalGroupId: 'sg-lane-4-right', routeName: '' },
  { id: 'assignment-6', laneId: 'lane-5', signalGroupId: 'sg-lane-5-and-5a-left', routeName: '' },
  { id: 'assignment-7', laneId: 'lane-5a', signalGroupId: 'sg-lane-5-and-5a-left', routeName: '' },
  { id: 'assignment-8', laneId: 'lane-6', signalGroupId: 'sg-lane-6-right', routeName: '' },
  { id: 'assignment-9', laneId: 'lane-7', signalGroupId: 'sg-lane-7-straight', routeName: '' },
  { id: 'assignment-10', laneId: 'lane-8', signalGroupId: 'sg-lane-8-straight', routeName: '' },
  { id: 'assignment-11', laneId: 'lane-8', signalGroupId: 'sg-lane-8-left', routeName: 'Tram 11 Heiderand' },
  { id: 'assignment-12', laneId: 'lane-8', signalGroupId: 'sg-lane-8-left', routeName: 'Tram 11 Rehfeld' },
  { id: 'assignment-13', laneId: 'lane-10', signalGroupId: 'sg-lane-10-all-directions', routeName: '' },
  { id: 'assignment-14', laneId: 'lane-11', signalGroupId: 'sg-lane-11-right', routeName: '' },
];

function laneLabel(lane: LaneFixture): string {
  return `${lane.name} (Signal ${lane.signalId})`;
}

function LaneTitle({ lane }: { lane: LaneFixture }) {
  return (
    <Stack direction="row" spacing={1} alignItems="center" sx={{ flexWrap: 'wrap' }}>
      <Typography variant="body1" fontWeight={700}>
        {lane.name}
      </Typography>
      <Chip size="small" variant="outlined" label={`Signal ${lane.signalId}`} />
      <Stack direction="row" spacing={0.25}>
        {lane.directions.map((direction) => {
          const DirectionIcon = directionIcons[direction];
          return (
            <Box
              key={direction}
              sx={{
                alignItems: 'center',
                border: '1px solid',
                borderColor: 'success.main',
                borderRadius: 1,
                color: 'success.main',
                display: 'inline-flex',
                height: 26,
                justifyContent: 'center',
                width: 30,
              }}
            >
              <DirectionIcon fontSize="small" />
            </Box>
          );
        })}
      </Stack>
    </Stack>
  );
}

function routeLabel(routeName: string): string {
  return routeName || 'Standard';
}

function assignmentKey(laneId: string, routeName: string): string {
  return `${laneId}\n${routeName}`;
}

function IntersectionLaneSignalGroupDndExample() {
  const [assignments, setAssignments] = useState(initialAssignments);
  const [selectedRouteName, setSelectedRouteName] = useState('');
  const [message, setMessage] = useState('Signalgruppe ziehen und auf eine Fahrspur fallen lassen.');

  const lanesById = useMemo(() => new Map(lanes.map((lane) => [lane.id, lane])), []);
  const signalGroupsById = useMemo(() => new Map(signalGroups.map((signalGroup) => [signalGroup.id, signalGroup])), []);
  const usedAssignmentKeys = useMemo(
    () => new Set(assignments.map((assignment) => assignmentKey(assignment.laneId, assignment.routeName))),
    [assignments],
  );

  function canAssign(laneId: string, routeName: string): boolean {
    return !usedAssignmentKeys.has(assignmentKey(laneId, routeName));
  }

  function onSignalGroupDragStart(event: DragEvent<HTMLElement>, signalGroupId: string) {
    event.dataTransfer.setData('application/x-ce-signal-group-id', signalGroupId);
    event.dataTransfer.effectAllowed = 'copy';
  }

  function onDrop(event: DragEvent<HTMLElement>, laneId: string) {
    event.preventDefault();
    const signalGroupId = event.dataTransfer.getData('application/x-ce-signal-group-id');
    const lane = lanesById.get(laneId);
    const signalGroup = signalGroupsById.get(signalGroupId);
    if (!lane || !signalGroup) return;

    if (!canAssign(laneId, selectedRouteName)) {
      setMessage(`${laneLabel(lane)} ist fuer ${routeLabel(selectedRouteName)} bereits zugeordnet.`);
      return;
    }

    setAssignments((current) => [
      ...current,
      {
        id: `assignment-${Date.now()}`,
        laneId,
        signalGroupId,
        routeName: selectedRouteName,
      },
    ]);
    setMessage(`${signalGroup.name} wurde ${laneLabel(lane)} fuer ${routeLabel(selectedRouteName)} zugeordnet.`);
  }

  function removeAssignment(id: string) {
    setAssignments((current) => current.filter((assignment) => assignment.id !== id));
  }

  return (
    <Stack spacing={2} sx={{ maxWidth: 1180 }}>
      <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems={{ md: 'center' }}>
        <FormControl sx={{ minWidth: 260 }}>
          <InputLabel>Route</InputLabel>
          <Select
            label="Route"
            value={selectedRouteName}
            onChange={(event) => setSelectedRouteName(event.target.value)}
          >
            {routeNames.map((routeName) => (
              <MenuItem key={routeName || 'standard'} value={routeName}>
                {routeLabel(routeName)}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
        <Typography variant="body2" color="text.secondary">
          {message}
        </Typography>
      </Stack>

      <Stack direction={{ xs: 'column', lg: 'row' }} spacing={2} alignItems="flex-start">
        <Stack spacing={1.5} sx={{ flex: 1, minWidth: 0 }}>
          {lanes.map((lane) => {
            const laneAssignments = assignments.filter((assignment) => assignment.laneId === lane.id);
            const assignable = canAssign(lane.id, selectedRouteName);
            return (
              <Paper
                key={lane.id}
                variant="outlined"
                onDragOver={(event) => {
                  if (assignable) event.preventDefault();
                }}
                onDrop={(event) => onDrop(event, lane.id)}
                sx={{
                  borderColor: assignable ? 'divider' : 'warning.main',
                  borderStyle: 'dashed',
                  p: 1.5,
                }}
              >
                <Stack spacing={1.25}>
                  <LaneTitle lane={lane} />
                  {laneAssignments.length === 0 ? (
                    <Typography variant="body2" color="text.secondary">
                      Keine Signalgruppe
                    </Typography>
                  ) : (
                    <Stack spacing={0.75}>
                      {laneAssignments.map((assignment) => {
                        const signalGroup = signalGroupsById.get(assignment.signalGroupId);
                        if (!signalGroup) return null;
                        return (
                          <Stack
                            key={assignment.id}
                            direction={{ xs: 'column', sm: 'row' }}
                            spacing={1}
                            alignItems={{ sm: 'center' }}
                            sx={{
                              borderRadius: 1,
                              bgcolor: signalGroup.tone,
                              border: '1px solid',
                              borderColor: 'divider',
                              px: 1,
                              py: 0.75,
                            }}
                          >
                            <Box sx={{ flex: 1, minWidth: 0 }}>
                              <Typography variant="body2" fontWeight={600} noWrap>
                                {signalGroup.name}
                              </Typography>
                              <Chip size="small" label={routeLabel(assignment.routeName)} />
                            </Box>
                            <Button size="small" color="error" onClick={() => removeAssignment(assignment.id)}>
                              Entfernen
                            </Button>
                          </Stack>
                        );
                      })}
                    </Stack>
                  )}
                </Stack>
              </Paper>
            );
          })}
        </Stack>

        <Paper variant="outlined" sx={{ p: 2, width: { xs: 1, lg: 360 } }}>
          <Typography variant="h6" sx={{ mb: 1 }}>
            Signalgruppen
          </Typography>
          <Stack spacing={1}>
            {signalGroups.map((signalGroup) => (
              <Box
                key={signalGroup.id}
                draggable
                onDragStart={(event) => onSignalGroupDragStart(event, signalGroup.id)}
                sx={{
                  border: '1px solid',
                  borderColor: 'divider',
                  bgcolor: signalGroup.tone,
                  borderRadius: 1,
                  cursor: 'grab',
                  px: 1.25,
                  py: 1,
                }}
              >
                <Typography variant="body2" fontWeight={600}>
                  {signalGroup.name}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  auf Fahrspur ziehen
                </Typography>
              </Box>
            ))}
          </Stack>
        </Paper>
      </Stack>
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Lane Signal Group DnD',
  component: IntersectionLaneSignalGroupDndExample,
} satisfies Meta<typeof IntersectionLaneSignalGroupDndExample>;

export default meta;
type Story = StoryObj<typeof meta>;

export const MappingPrototype: Story = {};
