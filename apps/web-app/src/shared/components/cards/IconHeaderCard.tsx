import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Divider from '@mui/material/Divider';
import type { ReactNode } from 'react';

export interface IconHeaderCardProps {
  children?: ReactNode;
  title: ReactNode;
  subtitle?: ReactNode;
  icon?: ReactNode;
  selected?: boolean;
  headerOnly?: boolean;
}

function IconHeaderCard(props: IconHeaderCardProps) {
  return (
    <Card sx={{ height: 1, width: 1, ...(props.selected && { outline: '2px solid', outlineColor: 'primary.main' }) }}>
      <CardHeader
        {...(props.icon !== undefined ? { avatar: props.icon } : {})}
        title={props.title}
        {...(props.subtitle !== undefined ? { subheader: props.subtitle } : {})}
        slotProps={{
          content: { sx: { display: 'flex', flexDirection: 'column', gap: 0.25, minWidth: 0 } },
          title: {
            variant: 'h5',
            sx: { lineHeight: 1, textOverflow: 'ellipsis', whiteSpace: 'nowrap' },
          },
          subheader: { variant: 'subtitle1', sx: { display: 'block', lineHeight: 1, mt: 0 } },
        }}
      />
      {!props.headerOnly && props.children !== undefined && (
        <>
          <Divider />
          <CardContent>{props.children}</CardContent>
        </>
      )}
    </Card>
  );
}

export default IconHeaderCard;
