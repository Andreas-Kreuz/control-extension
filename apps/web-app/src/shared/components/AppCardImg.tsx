import MuiBox from '@mui/material/Box';
import MuiCard from '@mui/material/Card';
import MuiCardActionArea from '@mui/material/CardActionArea';
import MuiCardMedia from '@mui/material/CardMedia';
import MuiChip from '@mui/material/Chip';
import MuiStack from '@mui/material/Stack';
import MuiTypography from '@mui/material/Typography';
import { Link as RouterLink } from 'react-router-dom';

export interface AppCardImgProps {
  title: string;
  subtitle?: string;
  id?: string;
  image?: string;
  to?: string;
  small?: boolean;
}

function AppCardImg(props: AppCardImgProps) {
  const contents = (
    <>
      <MuiTypography variant="h5">{props.title}</MuiTypography>
      {props.subtitle && (
        <MuiTypography variant="body1" sx={{ color: 'text.secondary' }}>
          {props.subtitle}
        </MuiTypography>
      )}
      {props.id && <MuiChip label={props.id} />}
    </>
  );

  const stack = (
    <MuiStack sx={{ flexDirection: { xs: 'row', sm: 'column' }, width: 1 }}>
      {props.image && (
        <MuiBox
          sx={{
            aspectRatio: '4 / 3',
            flex: { xs: '0 0 25%', sm: '0 0 auto' },
            width: { sm: 1 },
            overflow: 'hidden',
          }}
        >
          <MuiCardMedia
            component="img"
            image={props.image}
            title={props.title}
            sx={{
              width: 1,
              height: 1,
              objectFit: 'cover',
            }}
          />
        </MuiBox>
      )}
      <MuiBox sx={{ p: 2, flex: 1, minWidth: 0 }}>{contents}</MuiBox>
    </MuiStack>
  );

  return (
    <MuiCard sx={{ flexGrow: 1, display: 'flex', alignItems: 'stretch', alignContent: 'stretch' }}>
      {(props.to && (
        <MuiCardActionArea
          sx={{ display: 'flex', alignItems: 'stretch', alignContent: 'stretch', width: 1 }}
          component={RouterLink}
          to={props.to}
        >
          {stack}
        </MuiCardActionArea>
      )) || <MuiBox sx={{ display: 'flex', alignItems: 'stretch', alignContent: 'stretch', width: 1 }}>{stack}</MuiBox>}
    </MuiCard>
  );
}

export default AppCardImg;
