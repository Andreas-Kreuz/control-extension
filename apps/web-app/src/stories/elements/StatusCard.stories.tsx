import CheckCircleOutlineRoundedIcon from '@mui/icons-material/CheckCircleOutlineRounded';
import RunningWithErrorsRoundedIcon from '@mui/icons-material/RunningWithErrorsRounded';
import WarningRoundedIcon from '@mui/icons-material/WarningRounded';
import type { Meta, StoryObj } from '@storybook/react';
import StatusCard from '../../shared/components/cards/StatusCard';

const meta = {
  title: 'Elements/Cards/StatusCard',
  component: StatusCard,
} satisfies Meta<typeof StatusCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Success: Story = {
  args: {
    title: 'Title',
    statusText: 'OK',
    subtitle: 'Subtitle',
    statusColor: 'success',
    icon: <CheckCircleOutlineRoundedIcon sx={{ fontSize: 24 }} />,
  },
};

export const Warning: Story = {
  args: {
    title: 'Title',
    statusText: 'Warning',
    subtitle: 'Subtitle',
    statusColor: 'warning',
    icon: <RunningWithErrorsRoundedIcon sx={{ fontSize: 24 }} />,
  },
};

export const Error: Story = {
  args: {
    title: 'Title',
    statusText: 'Error',
    subtitle: 'Subtitle',
    statusColor: 'error',
    icon: <WarningRoundedIcon sx={{ fontSize: 24 }} />,
  },
};
