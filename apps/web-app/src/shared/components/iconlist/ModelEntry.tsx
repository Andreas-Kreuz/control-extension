import ViewInArIcon from '@mui/icons-material/ViewInAr';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function ModelEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<ViewInArIcon />} title="Modell" value={props.value} />;
}

export default ModelEntry;
