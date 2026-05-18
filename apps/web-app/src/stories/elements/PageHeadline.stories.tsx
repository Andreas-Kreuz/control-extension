import DashboardIcon from '@mui/icons-material/Dashboard';
import TuneIcon from '@mui/icons-material/Tune';
import IconButton from '@mui/material/IconButton';
import type { Meta, StoryObj } from '@storybook/react';
import PageContainer from '../../shared/layouts/PageContainer';
import PageHeadline from '../../shared/layouts/PageHeadline';

const meta = {
  title: 'Elements/Typography/PageHeadline',
  component: PageHeadline,
  parameters: {
    layout: 'fullscreen',
  },
  decorators: [
    (Story) => (
      <PageContainer>
        <Story />
      </PageContainer>
    ),
  ],
} satisfies Meta<typeof PageHeadline>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    children: 'Gleissystem',
  },
};

export const WithIcon: Story = {
  args: {
    children: 'Aktiver Zug',
    icon: <DashboardIcon color="primary" />,
  },
};

export const WithIconAndSettings: Story = {
  args: {
    children: 'Aktiver Zug',
    icon: <DashboardIcon color="primary" />,
    rightSettings: (
      <IconButton aria-label="Einstellungen">
        <TuneIcon />
      </IconButton>
    ),
  },
};
