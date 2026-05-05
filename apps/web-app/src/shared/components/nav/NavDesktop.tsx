import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import type { NavItem } from './NavItem';
import NavDesktopItem from './NavDesktopItem';

export const NAV_DESKTOP_WIDTH = 240;

function NavDesktop(props: { items: NavItem[]; activeIndex: number; onNavigate: (path: string) => void }) {
  return (
    <Drawer
      variant="permanent"
      sx={{
        width: NAV_DESKTOP_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: NAV_DESKTOP_WIDTH,
          boxSizing: 'border-box',
          top: 64,
          height: 'calc(100% - 64px)',
        },
      }}
    >
      <List sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, height: 1, p: 0.5 }}>
        {props.items.map((item, index) => (
          <NavDesktopItem
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

export default NavDesktop;
