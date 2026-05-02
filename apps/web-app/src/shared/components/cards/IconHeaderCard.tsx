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
        slotProps={{ title: { variant: 'subtitle1' } }}
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
