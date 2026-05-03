import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import BorderedSimpleCard from '../../shared/components/cards/BorderedSimpleCard';

const meta = {
  title: 'Elements/Cards/BorderedSimpleCard',
  component: BorderedSimpleCard,
} satisfies Meta<typeof BorderedSimpleCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    children: (
      <Stack spacing={1}>
        <Typography variant="subtitle2" color="text.secondary">
          Installierte Version
        </Typography>
        <Typography variant="h6">0.0.4</Typography>
      </Stack>
    ),
  },
};
