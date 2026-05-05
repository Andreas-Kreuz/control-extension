import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import RootLayout from '../../app/components/RootLayout';
import navItems from '../../app/hooks/navItems';
import type { NavItem } from '../../shared/components/nav';

const storyNavItems: NavItem[] = navItems.map(({ requiredModuleId: _requiredModuleId, ...navItem }) => navItem);

function NavStory() {
  return (
    <MemoryRouter initialEntries={['/train/list']}>
      <Routes>
        <Route element={<RootLayout navItems={storyNavItems} />}>
          <Route
            path="/"
            element={
              <Box sx={{ p: 3 }}>
                <Typography variant="h4">Start</Typography>
              </Box>
            }
          />
          {storyNavItems.map((navItem) => (
            <Route
              key={navItem.path}
              path={navItem.path}
              element={
                <Box sx={{ p: 3 }}>
                  <Typography variant="h4">{navItem.label}</Typography>
                </Box>
              }
            />
          ))}
        </Route>
      </Routes>
    </MemoryRouter>
  );
}

const meta = {
  title: 'Features/Layout/Nav',
  component: NavStory,
  parameters: {
    layout: 'fullscreen',
  },
} satisfies Meta<typeof NavStory>;

export default meta;
type Story = StoryObj<typeof meta>;

export const NavDesktop: Story = {};

export const NavTablet: Story = {
  globals: {
    viewport: { value: 'tablet', isRotated: false },
  },
};

export const NavMobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
