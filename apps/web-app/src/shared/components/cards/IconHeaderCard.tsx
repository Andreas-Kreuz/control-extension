import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Divider from '@mui/material/Divider';
import type { ReactNode } from 'react';
import { IconHeadline } from '../headlines';

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
        title={<IconHeadline text={props.title} icon={props.icon} />}
        {...(props.subtitle !== undefined ? { subheader: props.subtitle } : {})}
        slotProps={{
          content: { sx: { display: 'flex', flexDirection: 'column', gap: 0.25, minWidth: 0 } },
          title: { sx: { minWidth: 0 } },
          subheader: { variant: 'subtitle1', sx: { display: 'block', lineHeight: 1, mt: 0 } },
        }}
      />
      {!props.headerOnly && props.children !== undefined && (
        <>
          <Divider />
          <CardContent sx={{ '--section-content-px': '16px', p: 2, '&:last-child': { pb: 2 } }}>
            {props.children}
          </CardContent>
        </>
      )}
    </Card>
  );
}

export default IconHeaderCard;
