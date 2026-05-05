import SpeedIcon from '@mui/icons-material/Speed';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function SpeedEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<SpeedIcon />} title="Geschwindigkeit" value={props.value} />;
}

export default SpeedEntry;
