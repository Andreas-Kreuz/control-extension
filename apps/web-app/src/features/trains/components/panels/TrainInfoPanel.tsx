import { TrainAppDto } from '@ce/web-shared';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import { SpeedControl } from '../../../../shared/components/controls';
import {
  LicencePlateEntry,
  NameEntry,
  RouteEntry,
  SpeedEntry,
  VehicleNumberEntry,
} from '../../../../shared/components/iconlist';
import { FullBleedDivider } from '../../../../shared/components/sections';
import TrainLinePanel from './TrainLinePanel';

export type TransitInfo = {
  line: string;
  destination: string;
  nextStations: NonNullable<TrainAppDto['nextStations']>;
};

function TrainInfoPanel(props: {
  licencePlates?: string[];
  train: TrainAppDto;
  transit?: TransitInfo;
  vehicleNumbers?: string[];
  onSpeedCommit: (value: number) => void;
}) {
  const { train } = props;

  return (
    <>
      <List
        dense
        disablePadding
        sx={{
          p: 0,
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        <NameEntry value={train.name || '-'} />
        <RouteEntry value={train.route || '-'} />
        {!!props.vehicleNumbers?.length && <VehicleNumberEntry value={props.vehicleNumbers.join(', ')} />}
        {!!props.licencePlates?.length && <LicencePlateEntry value={props.licencePlates.join(', ')} />}
        <SpeedEntry value={`${train.speed} km/h`} />
        <ListItem sx={{ alignItems: 'flex-start', m: 0, p: 0 }}>
          <SpeedControl value={train.targetSpeed} onCommit={props.onSpeedCommit} />
        </ListItem>
      </List>
      {props.transit && (
        <>
          <FullBleedDivider />
          <TrainLinePanel
            line={props.transit.line}
            destination={props.transit.destination}
            nextStations={props.transit.nextStations}
          />
        </>
      )}
    </>
  );
}

export default TrainInfoPanel;
