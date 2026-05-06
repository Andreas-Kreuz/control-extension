import DirectionsBoatIcon from '@mui/icons-material/DirectionsBoat';
import DirectionsBusIcon from '@mui/icons-material/DirectionsBus';
import DirectionsRailwayIcon from '@mui/icons-material/DirectionsRailway';
import DirectionsSubwayIcon from '@mui/icons-material/DirectionsSubway';
import TramIcon from '@mui/icons-material/Tram';
import Avatar from '@mui/material/Avatar';
import type { SxProps, Theme } from '@mui/material/styles';
import { blue, cyan, green, orange, red } from '@mui/material/colors';

export type LineTrafficType = 'BUS' | 'FERRY' | 'SBAHN' | 'SUBWAY' | 'TRAIN' | 'TRAM' | string;

function getLineIcon(trafficType: LineTrafficType) {
  switch (trafficType) {
    case 'FERRY':
      return <DirectionsBoatIcon />;
    case 'SBAHN':
    case 'TRAIN':
      return <DirectionsRailwayIcon />;
    case 'SUBWAY':
      return <DirectionsSubwayIcon />;
    case 'TRAM':
      return <TramIcon />;
    case 'BUS':
    default:
      return <DirectionsBusIcon />;
  }
}

function getLineColor(trafficType: LineTrafficType) {
  switch (trafficType) {
    case 'FERRY':
      return cyan[700];
    case 'SBAHN':
    case 'TRAIN':
      return green[500];
    case 'SUBWAY':
      return red[500];
    case 'TRAM':
      return blue[500];
    case 'BUS':
    default:
      return orange[700];
  }
}

function LineAvatar(props: { trafficType: LineTrafficType; sx?: SxProps<Theme> }) {
  return (
    <Avatar aria-label={`${props.trafficType} Linie`} sx={{ bgcolor: getLineColor(props.trafficType), ...props.sx }}>
      {getLineIcon(props.trafficType)}
    </Avatar>
  );
}

export { getLineColor, getLineIcon };
export default LineAvatar;
