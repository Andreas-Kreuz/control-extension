import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import type { NavItem } from './NavItem';

function NavTabletItem(props: { item: NavItem; selected: boolean; onNavigate: (path: string) => void }) {
  return (
    <Tooltip title={props.item.label} placement="right">
      <ListItemButton
        selected={props.selected}
        onClick={() => props.onNavigate(props.item.path)}
        sx={{
          borderRadius: 1,
          flex: '0 0 auto',
          flexDirection: 'column',
          justifyContent: 'center',
          py: 1,
          px: 0,
          minHeight: 64,
        }}
      >
        <ListItemIcon sx={{ justifyContent: 'center', minWidth: 'auto' }}>{props.item.icon}</ListItemIcon>
        <Typography variant="caption" align="center" noWrap sx={{ fontSize: '0.6rem', width: '100%' }}>
          {props.item.label}
        </Typography>
      </ListItemButton>
    </Tooltip>
  );
}

export default NavTabletItem;
