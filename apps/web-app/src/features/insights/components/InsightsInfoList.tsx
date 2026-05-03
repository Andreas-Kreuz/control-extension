import Link from '@mui/material/Link';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { ReactNode } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import OutlinedCard from '../../../shared/components/cards/OutlinedCard';

interface InsightsInfoListItem {
  icon: ReactNode;
  label: string;
  value: string;
  href?: string;
  valuePrefix?: ReactNode;
  valueIcon?: ReactNode;
  tooltip?: string;
}

function InsightsInfoRow(props: InsightsInfoListItem) {
  const row = (
    <ListItem
      aria-label={props.tooltip}
      disableGutters
      sx={{
        alignItems: 'center',
        color: 'text.primary',
        minHeight: 26,
        minWidth: 0,
        py: 0,
      }}
    >
      <ListItemIcon sx={{ alignItems: 'center', color: 'text.secondary', minWidth: 30 }}>{props.icon}</ListItemIcon>
      <ListItemText
        primary={props.label}
        slotProps={{
          primary: {
            variant: 'body2',
            sx: { fontWeight: 500, lineHeight: 1.2 },
          },
        }}
        sx={{ minWidth: 0, mr: 1, my: 0 }}
      />
      <Stack direction="row" spacing={0.75} sx={{ alignItems: 'center', flex: '0 0 auto', minWidth: 0 }}>
        {props.valuePrefix}
        {props.href ? (
          <Link
            component={RouterLink}
            to={props.href}
            variant="body2"
            sx={{ lineHeight: 1.2, overflowWrap: 'anywhere', textAlign: 'right' }}
          >
            {props.value}
          </Link>
        ) : (
          <Typography variant="body2" sx={{ lineHeight: 1.2, overflowWrap: 'anywhere', textAlign: 'right' }}>
            {props.value}
          </Typography>
        )}
        {props.valueIcon}
      </Stack>
    </ListItem>
  );

  if (props.tooltip) {
    return <Tooltip title={props.tooltip}>{row}</Tooltip>;
  }

  return row;
}

function InsightsInfoList(props: { title: string; description: string; items: InsightsInfoListItem[] }) {
  return (
    <OutlinedCard title={props.title} description={props.description}>
      <List
        disablePadding
        sx={{
          display: 'flex',
          flexDirection: 'column',
          gap: 1,
          minWidth: 0,
          width: 1,
        }}
      >
        {props.items.map((item) => (
          <InsightsInfoRow key={item.label} {...item} />
        ))}
      </List>
    </OutlinedCard>
  );
}

export default InsightsInfoList;
