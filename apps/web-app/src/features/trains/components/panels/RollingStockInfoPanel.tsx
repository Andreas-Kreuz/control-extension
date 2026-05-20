import { RollingStockAppDto } from '@ce/web-shared';
import List from '@mui/material/List';
import {
  HookStatusEntry,
  LengthEntry,
  LicencePlateEntry,
  ModelEntry,
  NameEntry,
  OrientationEntry,
  PropelledEntry,
  TagEntry,
  TrainPositionEntry,
  VehicleNumberEntry,
} from '../../../../shared/components/iconlist';
import { formatHookStatus, formatLength, formatRollingStockModel } from '../../lib/rollingStockDisplay';
import BreakableModelValue from './BreakableModelValue';

function RollingStockInfoPanel(props: { rollingStock: RollingStockAppDto }) {
  return (
    <List
      dense
      disablePadding
      sx={{
        pt: 0,
        '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
      }}
    >
      <NameEntry value={props.rollingStock.name || '-'} />
      <TagEntry value={props.rollingStock.tag || '-'} />
      <VehicleNumberEntry value={props.rollingStock.vehicleNumber || props.rollingStock.nr || '-'} />
      <LicencePlateEntry value={props.rollingStock.licencePlate || '-'} />
      <HookStatusEntry value={formatHookStatus(props.rollingStock.hookStatus)} />
      <TrainPositionEntry value={String(props.rollingStock.positionInTrain + 1)} />
      <ModelEntry value={<BreakableModelValue value={formatRollingStockModel(props.rollingStock)} />} />
      <LengthEntry value={formatLength(props.rollingStock.length)} />
      <PropelledEntry value={props.rollingStock.propelled ? 'Ja' : 'Nein'} />
      <OrientationEntry value={props.rollingStock.orientationForward ? 'Vorwärts' : 'Rückwärts'} />
    </List>
  );
}

export default RollingStockInfoPanel;
