import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import type { NavItem } from './NavItem';
import NavTabletItem from './NavTabletItem';

export const NAV_TABLET_WIDTH = 80;

function NavTablet(props: { items: NavItem[]; activeIndex: number; onNavigate: (path: string) => void }) {
  return (
    <Drawer
      variant="permanent"
      sx={{
        width: NAV_TABLET_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: NAV_TABLET_WIDTH,
          boxSizing: 'border-box',
          overflowX: 'hidden',
          top: 48,
          height: 'calc(100% - 48px)',
        },
      }}
    >
      <List disablePadding sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, height: 1, p: 0.5 }}>
        {props.items.map((item, index) => (
          <NavTabletItem
            key={item.path}
            item={item}
            selected={props.activeIndex === index}
            onNavigate={props.onNavigate}
          />
        ))}
        <Box sx={{ flex: '1 1 auto' }} />
      </List>
    </Drawer>
  );
}

export default NavTablet;
