import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { ReactNode } from 'react';
import { Link as RouterLink } from 'react-router-dom';

export interface BackgroundImageCardProps {
  children?: ReactNode;
  title: string;
  subtitle?: string;
  id?: string;
  additionalChips?: ReactNode[];
  to?: string;
  icon?: string;
  framedIcon?: boolean;
  image?: string;
  small?: boolean;
  expanded?: boolean;
  selected?: boolean;
  setExpanded?: (expanded: boolean) => void;
}

function BackgroundImageCard(props: BackgroundImageCardProps) {
  const handleExpand = () => {
    if (props.setExpanded) {
      props.setExpanded(!props.expanded);
    }
  };
  const actionAreaProps = props.to
    ? {
        component: RouterLink,
        to: props.to,
      }
    : {};
  const contents = (
    <Stack sx={{ flexDirection: 'column', alignItems: 'fill' }}>
      <CardActionArea
        {...actionAreaProps}
        onClick={handleExpand}
        disableRipple={((props.setExpanded || !props.to) && true) || false}
        sx={{
          alignItems: 'flex-start',
          display: 'flex',
          flexDirection: 'column',
          gap: 0.25,
          p: 2,
          background:
            'radial-gradient(circle at right, ' +
            'rgba(255,255,255,0) 0px, rgba(255,255,255,0) 100px, rgba(255,255,255,1) 200px), ' +
            'url(' +
            props.image +
            ')',
          backgroundSize: 'auto 150%',
          backgroundPositionX: '100%',
          backgroundPositionY: '60%',
          backgroundRepeat: 'no-repeat',
        }}
      >
        <Typography variant="h5" sx={{ lineHeight: 1 }}>
          {props.title}
        </Typography>
        {props.subtitle && (
          <Typography variant="subtitle1" sx={{ color: 'text.secondary', lineHeight: 1 }}>
            {props.subtitle}
          </Typography>
        )}
        <Stack
          direction="row"
          spacing={1}
          sx={{ pt: 0.5, '& .MuiChip-outlined': { backgroundColor: 'rgba(255,255,255,0.8)' } }}
        >
          {props.icon &&
            (props.framedIcon ? (
              <Box
                component="span"
                sx={{
                  width: 48,
                  height: 32,
                  p: '2px',
                  border: 1,
                  borderColor: 'grey.700',
                  borderRadius: '4px',
                  boxSizing: 'border-box',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                <Box component="img" src={props.icon} alt="" sx={{ width: 1, height: 1, objectFit: 'contain' }} />
              </Box>
            ) : (
              <img src={props.icon} height="32" alt="" />
            ))}
          {props.id && <Chip label={props.id} />}
          {props.additionalChips && props.additionalChips.map((e) => e)}
        </Stack>
      </CardActionArea>
      {props.children}
    </Stack>
  );

  return (
    <Card sx={{ flexGrow: 1, ...(props.selected && { outline: '2px solid', outlineColor: 'primary.main' }) }}>
      {contents}
    </Card>
  );
}

export default BackgroundImageCard;
