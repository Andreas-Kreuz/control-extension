import { TrainListAppDto } from '@ce/web-shared';
import List from '@mui/material/List';
import { NameEntry, RouteEntry, SpeedEntry } from '../../../../shared/components/iconlist';

function TrainInformationPanel(props: { train: TrainListAppDto; targetSpeed?: number }) {
  return (
    <List
      dense
      disablePadding
      sx={{
        '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
      }}
    >
      <NameEntry value={props.train.name || '-'} />
      <RouteEntry value={props.train.route || '-'} />
      <SpeedEntry value={props.targetSpeed !== undefined ? `${props.targetSpeed} km/h` : '-'} />
    </List>
  );
}

export default TrainInformationPanel;
