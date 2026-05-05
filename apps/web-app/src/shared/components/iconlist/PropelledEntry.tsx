import SpeedIcon from '@mui/icons-material/Speed';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function PropelledEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<SpeedIcon />} title="Antrieb" value={props.value} />;
}

export default PropelledEntry;
