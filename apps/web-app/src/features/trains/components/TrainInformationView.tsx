import { TrainListDto } from '@ce/web-shared';
import DirectionsIcon from '@mui/icons-material/Directions';
import LabelIcon from '@mui/icons-material/Label';
import SpeedIcon from '@mui/icons-material/Speed';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';

function TrainInformationView(props: { train: TrainListDto; targetSpeed?: number }) {
  const { train, targetSpeed } = props;
  const infoRows = [
    { label: 'Name des Zuges', value: train.name || '-', icon: LabelIcon },
    { label: 'Route aus EEP', value: train.route || '-', icon: DirectionsIcon },
    {
      label: 'Zielgeschwindigkeit',
      value: targetSpeed !== undefined ? `${targetSpeed} km/h` : '-',
      icon: SpeedIcon,
    },
  ];

  return (
    <List
      dense
      sx={{
        '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
      }}
    >
      {infoRows.map((row) => (
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

export default TrainInformationView;
