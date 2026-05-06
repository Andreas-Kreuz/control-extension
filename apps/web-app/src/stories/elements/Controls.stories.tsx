import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import { fn } from 'storybook/test';
import {
  AxisList,
  AxisSlider,
  BlinkerLeftControl,
  BlinkerRightControl,
  BrakeLightControl,
  CameraControl,
  ControlGrid,
  CouplingControl,
  DrivingLightControl,
  SpeedControl,
} from '../../shared/components/controls';

const cameras = [
  { key: 3, label: 'Links oben' },
  { key: 4, label: 'Rechts oben' },
  { key: 8, label: 'Führerstand' },
  { key: -1, label: 'Front' },
  { key: -2, label: 'Front 2' },
  { key: 10, label: 'Kabine' },
];

function ControlsOverview() {
  return (
    <Stack spacing={3} sx={{ maxWidth: 720 }}>
      <Box>
        <Typography variant="h6">Train controls</Typography>
        <ControlGrid>
          <CouplingControl value={1} label="Kupplung vorne" onChange={fn()} />
          <CouplingControl value={2} label="Kupplung hinten" onChange={fn()} />
          <DrivingLightControl checked onChange={fn()} />
          <BrakeLightControl checked={false} onChange={fn()} />
          <BlinkerLeftControl checked={false} onChange={fn()} />
          <BlinkerRightControl checked onChange={fn()} />
          <CameraControl cameras={cameras} onCameraSelect={fn()} />
        </ControlGrid>
      </Box>
      <Box>
        <Typography variant="h6">Speed</Typography>
        <List dense>
          <ListItem sx={{ alignItems: 'flex-start', m: 0, p: 0 }}>
            <SpeedControl value={80} onCommit={fn()} />
          </ListItem>
        </List>
      </Box>
      <Box>
        <Typography variant="h6">Axes</Typography>
        <Stack spacing={2}>
          <AxisSlider name="Tür links" value={45} trailingLabel="2x" onCommit={fn()} />
          <AxisList
            entries={[
              { axisNumber: 1, name: 'Pantograph', value: 100 },
              { axisNumber: 2, name: 'Tür rechts', value: 0 },
              { axisNumber: 3, name: 'Ladeklappe', value: 35 },
            ]}
            onCommit={fn()}
          />
        </Stack>
      </Box>
    </Stack>
  );
}

const meta = {
  title: 'Elements/Controls/Overview',
  component: ControlsOverview,
} satisfies Meta<typeof ControlsOverview>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Overview: Story = {};

export const OnMobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
