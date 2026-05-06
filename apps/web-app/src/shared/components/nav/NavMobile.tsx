import BottomNavigation from '@mui/material/BottomNavigation';
import BottomNavigationAction from '@mui/material/BottomNavigationAction';
import Paper from '@mui/material/Paper';
import type { NavItem } from './NavItem';

function NavMobile(props: { items: NavItem[]; activeIndex: number; onNavigate: (path: string) => void }) {
  return (
    <Paper
      sx={{ position: 'fixed', bottom: 0, left: 0, right: 0, border: 0, zIndex: (theme) => theme.zIndex.appBar }}
      elevation={3}
    >
      <BottomNavigation
        value={props.activeIndex}
        onChange={(_, newValue: number) => props.onNavigate(props.items[newValue]?.path ?? '/')}
        sx={{
          bgcolor: 'primary.main',
          '& .MuiBottomNavigationAction-root': { color: 'primary.contrastText', opacity: 0.7 },
          '& .MuiBottomNavigationAction-root.Mui-selected': { color: 'primary.contrastText', opacity: 1 },
        }}
      >
        {props.items.map((item) => (
          <BottomNavigationAction key={item.path} label={item.label} icon={item.icon} />
        ))}
      </BottomNavigation>
    </Paper>
  );
}

export default NavMobile;
