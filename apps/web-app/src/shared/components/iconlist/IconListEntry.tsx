import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import { ReactNode } from 'react';

function IconListEntry(props: { icon: ReactNode; title: string; value: ReactNode }) {
  return (
    <ListItem sx={{ alignItems: 'center', m: 0, p: 0 }}>
      <ListItemIcon>{props.icon}</ListItemIcon>
      <ListItemText primary={props.value} secondary={props.title} />
    </ListItem>
  );
}

export default IconListEntry;
