import FileUploadIcon from '@mui/icons-material/FileUpload';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function HookStatusEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<FileUploadIcon />} title="Kranhaken" value={props.value} />;
}

export default HookStatusEntry;
