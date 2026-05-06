import CompareArrowsIcon from '@mui/icons-material/CompareArrows';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function OrientationEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<CompareArrowsIcon />} title="Ausrichtung" value={props.value} />;
}

export default OrientationEntry;
