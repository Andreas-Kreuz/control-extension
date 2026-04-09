import LocationOnIcon from '@mui/icons-material/LocationOn';
import RouteIcon from '@mui/icons-material/Route';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';

function TrainLineInformationView(props: { line?: string; destination?: string }) {
  const rows = [
    { label: 'Linie', value: props.line ?? '-', icon: RouteIcon },
    { label: 'Ziel', value: props.destination ?? '-', icon: LocationOnIcon },
  ];

  return (
    <List
      dense
      sx={{
        '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
      }}
    >
      {rows.map((row) => (
        <ListItem key={row.label}>
          <ListItemIcon>
            <row.icon />
          </ListItemIcon>
          <ListItemText primary={row.value} secondary={row.label} />
        </ListItem>
      ))}
    </List>
  );
}

export default TrainLineInformationView;
