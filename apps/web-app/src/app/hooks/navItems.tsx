import CommuteIcon from '@mui/icons-material/Commute';
import HomeIcon from '@mui/icons-material/Home';
import TrafficIcon from '@mui/icons-material/Traffic';
import TramIcon from '@mui/icons-material/Tram';
import type { NavItem } from '../components/AppLayout';

const navItems: NavItem[] = [
  { icon: <HomeIcon />, label: 'Start', path: '/' },
  { icon: <CommuteIcon />, label: 'Fuhrpark', path: '/trains' },
  { icon: <TrafficIcon />, label: 'Ampeln', path: '/road' },
  { icon: <TramIcon />, label: 'ÖPNV', path: '/transit' },
];

export default navItems;
