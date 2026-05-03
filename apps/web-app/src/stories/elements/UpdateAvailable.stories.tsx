import type { Meta, StoryObj } from '@storybook/react';
import UpdateAvailable from '../../shared/components/update/UpdateAvailable';

const meta = {
  title: 'Elements/Update/UpdateAvailable',
  component: UpdateAvailable,
} satisfies Meta<typeof UpdateAvailable>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {},
};

export const CustomLabel: Story = {
  args: {
    label: 'Version 2.4.1 available',
  },
};
