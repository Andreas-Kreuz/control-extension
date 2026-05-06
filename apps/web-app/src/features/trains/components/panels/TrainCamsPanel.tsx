import VideocamIcon from '@mui/icons-material/Videocam';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';

export interface TrainCameraItem {
  key: number;
  label: string;
}

function TrainCamsPanel(props: { cameras: readonly TrainCameraItem[]; onCameraSelect: (key: number) => void }) {
  return (
    <List dense disablePadding>
      {props.cameras.map((camera) => (
        <ListItem key={camera.key} disablePadding>
          <ListItemButton sx={{ px: 0, py: 0.5 }} onClick={() => props.onCameraSelect(camera.key)}>
            <ListItemIcon sx={{ minWidth: 40 }}>
              <VideocamIcon />
            </ListItemIcon>
            <ListItemText primary={camera.label} />
          </ListItemButton>
        </ListItem>
      ))}
    </List>
  );
}

export default TrainCamsPanel;
