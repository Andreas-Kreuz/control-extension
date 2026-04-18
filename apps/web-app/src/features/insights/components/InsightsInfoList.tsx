import Box from '@mui/material/Box';
import Link from '@mui/material/Link';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { ReactNode } from 'react';

interface InsightsInfoListItem {
  icon: ReactNode;
  label: string;
  value: string;
  href?: string;
  valueIcon?: ReactNode;
  tooltip?: string;
}

function InsightsInfoListRow(props: InsightsInfoListItem) {
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
            variant: 'caption',
            sx: { fontWeight: 600, lineHeight: 1.2 },
          },
        }}
        sx={{ minWidth: 0, mr: 1, my: 0 }}
      />
      <Stack direction="row" spacing={0.75} sx={{ alignItems: 'center', flex: '0 0 auto', minWidth: 0 }}>
        {props.href ? (
          <Link
            href={props.href}
            variant="caption"
            sx={{ lineHeight: 1.2, overflowWrap: 'anywhere', textAlign: 'right' }}
          >
            {props.value}
          </Link>
        ) : (
          <Typography variant="caption" sx={{ lineHeight: 1.2, overflowWrap: 'anywhere', textAlign: 'right' }}>
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
    <Box
      sx={{
        alignItems: 'flex-start',
        border: 1,
        borderColor: 'divider',
        borderRadius: 1,
        display: 'flex',
        height: 1,
        minWidth: 0,
        p: 2,
        width: 1,
      }}
    >
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
        <Stack spacing={0.5} sx={{ mb: 0.5 }}>
          <Typography variant="h6" sx={{ lineHeight: 1 }}>
            {props.title}
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.secondary', lineHeight: 1 }}>
            {props.description}
          </Typography>
        </Stack>
        {props.items.map((item) => (
          <InsightsInfoListRow key={item.label} {...item} />
        ))}
      </List>
    </Box>
  );
}

export default InsightsInfoList;
