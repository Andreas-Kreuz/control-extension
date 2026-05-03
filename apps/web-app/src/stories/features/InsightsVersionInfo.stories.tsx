import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import { MemoryRouter } from 'react-router-dom';
import { InsightsVersionInfoContent } from '../../features/insights/components/InsightsVersionInfo';

const versions = {
  appVersion: 'v0.0.5-alpha',
  eepVersion: '17.0',
  luaVersion: '5.3',
};

const meta = {
  title: 'Features/Insights/InsightsVersionInfo',
  component: InsightsVersionInfoContent,
  decorators: [
    (Story) => (
      <MemoryRouter initialEntries={['/insights']}>
        <Story />
      </MemoryRouter>
    ),
  ],
} satisfies Meta<typeof InsightsVersionInfoContent>;

export default meta;
type Story = StoryObj<typeof meta>;

export const UpdateStatesSideBySide: Story = {
  render: () => (
    <Box
      sx={{
        display: 'grid',
        gap: 2,
        gridTemplateColumns: { xs: '1fr', md: 'repeat(2, minmax(280px, 360px))' },
        p: 2,
      }}
    >
      <Box sx={{ display: 'grid', gap: 1 }}>
        <Typography variant="subtitle2">Kein Update</Typography>
        <InsightsVersionInfoContent versions={versions} />
      </Box>
      <Box sx={{ display: 'grid', gap: 1 }}>
        <Typography variant="subtitle2">Update verfügbar</Typography>
        <InsightsVersionInfoContent availableUpdateVersion="v0.0.6-alpha" updateAvailable versions={versions} />
      </Box>
    </Box>
  ),
};
