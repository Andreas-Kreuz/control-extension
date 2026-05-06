import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import type { NavItem } from './NavItem';

function NavDesktopItem(props: { item: NavItem; selected: boolean; onNavigate: (path: string) => void }) {
  return (
    <ListItemButton
      selected={props.selected}
      onClick={() => props.onNavigate(props.item.path)}
      sx={{ borderRadius: 1, flex: '0 0 auto' }}
    >
      <ListItemIcon>{props.item.icon}</ListItemIcon>
      <ListItemText primary={props.item.label} />
    </ListItemButton>
  );
}

export default NavDesktopItem;
