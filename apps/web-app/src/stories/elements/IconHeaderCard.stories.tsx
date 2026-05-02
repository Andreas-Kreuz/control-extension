import DashboardIcon from '@mui/icons-material/Dashboard';
import type { Meta, StoryObj } from '@storybook/react';
import IconHeaderCard from '../../shared/components/cards/IconHeaderCard';

const meta = {
  title: 'Elements/Cards/IconHeaderCard',
  component: IconHeaderCard,
} satisfies Meta<typeof IconHeaderCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const TitleAndIcon: Story = {
  args: {
    title: 'Title',
    icon: <DashboardIcon color="primary" />,
    headerOnly: true,
  },
};

export const TitleSubtitleAndIcon: Story = {
  args: {
    title: 'Title',
    subtitle: 'Subtitle',
    icon: <DashboardIcon color="primary" />,
    headerOnly: true,
  },
};

export const Selected: Story = {
  args: {
    title: 'Title',
    subtitle: 'Subtitle',
    icon: <DashboardIcon color="primary" />,
    selected: true,
    headerOnly: true,
  },
};

export const OnMobile: Story = {
  args: {
    title: 'Title',
    subtitle: 'Subtitle',
    icon: <DashboardIcon color="primary" />,
    headerOnly: true,
  },
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
