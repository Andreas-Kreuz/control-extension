import InventoryIcon from '@mui/icons-material/Inventory';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function VehicleNumberEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<InventoryIcon />} title="Fahrzeugnummer" value={props.value} />;
}

export default VehicleNumberEntry;
