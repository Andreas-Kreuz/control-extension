import HomeIcon from '@mui/icons-material/Home';
import TramIcon from '@mui/icons-material/Tram';
import CommuteIcon from '@mui/icons-material/Commute';
import TrafficIcon from '@mui/icons-material/Traffic';
import type { NavItem } from '../components/AppLayout';

const useNavItems: NavItem[] = [
  { icon: <HomeIcon />, label: 'Start', path: '/' },
  { icon: <TrafficIcon />, label: 'Straße', path: '/road' },
  { icon: <TramIcon />, label: 'ÖPNV', path: '/transit' },
  { icon: <CommuteIcon />, label: 'Fuhrpark', path: '/trains' },
];

export default useNavItems;
