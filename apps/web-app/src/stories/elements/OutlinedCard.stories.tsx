import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import OutlinedCard from '../../shared/components/cards/OutlinedCard';

const meta = {
  title: 'Elements/Cards/OutlinedCard',
  component: OutlinedCard,
} satisfies Meta<typeof OutlinedCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    title: 'Informationen',
    description: 'Datenbestand und Laufzeit',
    children: (
      <Typography variant="body2" sx={{ color: 'text.secondary' }}>
        Outlined card content
      </Typography>
    ),
  },
};

export const HeaderOnly: Story = {
  args: {
    title: 'Informationen',
    description: 'Datenbestand und Laufzeit',
  },
};
