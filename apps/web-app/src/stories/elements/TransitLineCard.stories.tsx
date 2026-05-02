import TramIcon from '@mui/icons-material/Tram';
import type { Meta, StoryObj } from '@storybook/react';
import TransitLineCard from '../../shared/components/cards/TransitLineCard';

const meta = {
  title: 'Elements/Cards/TransitLineCard',
  component: TransitLineCard,
} satisfies Meta<typeof TransitLineCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const TitleBadgeAndIcon: Story = {
  args: {
    title: 'Destination A - Destination B',
    badge: '12',
    icon: <TramIcon />,
    iconColor: 'primary.main',
  },
};

export const TitleSubtitleBadgeAndIcon: Story = {
  args: {
    title: 'Destination A - Destination B',
    subtitle: 'Subtitle',
    badge: '12',
    icon: <TramIcon />,
    iconColor: 'primary.main',
  },
};

export const Selected: Story = {
  args: {
    title: 'Destination A - Destination B',
    subtitle: 'Subtitle',
    badge: '12',
    icon: <TramIcon />,
    iconColor: 'primary.main',
    selected: true,
  },
};

export const OnMobile: Story = {
  args: {
    title: 'Destination A - Destination B',
    subtitle: 'Subtitle',
    badge: '12',
    icon: <TramIcon />,
    iconColor: 'primary.main',
  },
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
