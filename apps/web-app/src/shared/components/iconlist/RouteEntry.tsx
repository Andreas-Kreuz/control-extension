import DirectionsIcon from '@mui/icons-material/Directions';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function RouteEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<DirectionsIcon />} title="EEP-Route" value={props.value} />;
}

export default RouteEntry;
