import type { Meta, StoryObj } from '@storybook/react';
import { fn } from 'storybook/test';
import { PlainCard } from './PlainCard.component';

// More on how to set up stories at: https://storybook.js.org/docs/writing-stories#default-export
const meta = {
  title: 'Elements/Cards/PlainCard',
  tags: ['autodocs'],
  component: PlainCard,
} satisfies Meta<typeof PlainCard>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {},
};

export const CardOnMobile: Story = {
  args: {},
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
