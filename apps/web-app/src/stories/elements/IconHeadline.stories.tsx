import DashboardIcon from '@mui/icons-material/Dashboard';
import type { Meta, StoryObj } from '@storybook/react';
import { trainSections } from '../../features/trains/components/trainSectionPresentation';
import { IconHeadline } from '../../shared/components/headlines';

const meta = {
  title: 'Elements/Headlines/IconHeadline',
  component: IconHeadline,
} satisfies Meta<typeof IconHeadline>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    text: 'Aktiver Zug',
    icon: <DashboardIcon color="primary" />,
  },
};

export const Neutral: Story = {
  args: {
    text: 'Aktiver Zug',
    icon: <DashboardIcon />,
  },
};

export const TrainAxes: Story = {
  args: {
    text: trainSections.trainAxes.title,
    icon: trainSections.trainAxes.icon,
  },
};

export const TrainAxesNeutral: Story = {
  args: {
    text: trainSections.trainAxes.title,
    icon: <DashboardIcon />,
  },
};
