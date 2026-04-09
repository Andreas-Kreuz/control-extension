import CamIcon from '@mui/icons-material/Videocam';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import useDebug from '../../../shared/socket/useDebug';
import useRollingStock from '../hooks/useRollingStock';
import useRollingStockDynamic from '../hooks/useRollingStockDynamic';
import useSetRollingStockCam from '../hooks/useSetRollingStockCam';
import useSetTrainCam from '../hooks/useSetTrainCam';

interface CameraData {
  key: number;
  label: string;
}

const cameraData: readonly CameraData[] = [
  { key: 3, label: 'Links oben' },
  { key: 4, label: 'Rechts oben' },
  { key: 8, label: 'Führerstand' },
  { key: -1, label: 'Front' },
  { key: -2, label: 'Front 2' },
  { key: 10, label: 'Kabine' },
];

const TrainCamList = (props: { trainName: string; rollingStockName: string }) => {
  const rollingStock = useRollingStock(props.rollingStockName);
  const rollingStockDynamic = useRollingStockDynamic(props.rollingStockName);
  const setRollingStockCam = useSetRollingStockCam();
  const setTrainCam = useSetTrainCam();
  const debug = useDebug();
  void rollingStockDynamic;

  const changeCam = (key: number) => {
    switch (key) {
      case -1:
      case -2: {
        if (debug) console.log('                 |📹 CAM SET-', props.rollingStockName, rollingStock);
        setRollingStockCam(rollingStock, key);
        setTrainCam(props.trainName, props.rollingStockName, 9);
        break;
      }
      default: {
        setTrainCam(props.trainName, props.rollingStockName, key);
      }
    }
  };

  return (
    <List dense disablePadding>
      {cameraData.map((data) => (
        <ListItem key={data.key} disablePadding>
          <ListItemButton onClick={() => changeCam(data.key)}>
            <ListItemIcon>
              <CamIcon />
            </ListItemIcon>
            <ListItemText primary={data.label} />
          </ListItemButton>
        </ListItem>
      ))}
    </List>
  );
};

export default TrainCamList;

