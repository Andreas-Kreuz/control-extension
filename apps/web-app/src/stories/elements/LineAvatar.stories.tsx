import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import LineAvatar from '../../shared/components/lines/LineAvatar';
import type { LineTrafficType } from '../../shared/components/lines/LineAvatar';

const variants: { label: string; line: string; trafficType: LineTrafficType }[] = [
  { label: 'Bus line', line: '65', trafficType: 'BUS' },
  { label: 'Tram line', line: 'M4', trafficType: 'TRAM' },
  { label: 'Underground line', line: 'U5', trafficType: 'SUBWAY' },
  { label: 'Ferry line', line: 'F12', trafficType: 'FERRY' },
  { label: 'S-Bahn line', line: 'S3', trafficType: 'SBAHN' },
];

function LineAvatarGallery() {
  return (
    <Stack spacing={2} sx={{ p: 3 }}>
      {variants.map((variant) => (
        <Stack key={variant.trafficType} direction="row" spacing={1.5} sx={{ alignItems: 'center' }}>
          <LineAvatar trafficType={variant.trafficType} />
          <Box sx={{ minWidth: 0 }}>
            <Typography variant="h6" sx={{ lineHeight: 1.1 }}>
              {variant.line}
            </Typography>
            <Typography variant="body2" color="textSecondary">
              {variant.label}
            </Typography>
          </Box>
        </Stack>
      ))}
    </Stack>
  );
}

const meta = {
  title: 'Elements/LineAvatar',
  component: LineAvatarGallery,
} satisfies Meta<typeof LineAvatarGallery>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AllVariants: Story = {};
