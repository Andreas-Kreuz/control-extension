import PinIcon from '@mui/icons-material/Pin';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function LicencePlateEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<PinIcon />} title="Kennzeichen" value={props.value} />;
}

export default LicencePlateEntry;
