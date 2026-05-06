import CommuteIcon from '@mui/icons-material/Commute';
import HomeIcon from '@mui/icons-material/Home';
import TrafficIcon from '@mui/icons-material/Traffic';
import TramIcon from '@mui/icons-material/Tram';
import type { NavItem } from '../../shared/components/nav';
import { hubCeModuleId, roadCeModuleId, transitCeModuleId } from '../../features/home/lib/NavElements';

const navItems: NavItem[] = [
  { icon: <HomeIcon />, label: 'Start', path: '/' },
  { icon: <CommuteIcon />, label: 'Fuhrpark', path: '/train/list', requiredModuleId: hubCeModuleId },
  { icon: <TrafficIcon />, label: 'Ampeln', path: '/road', requiredModuleId: roadCeModuleId },
  { icon: <TramIcon />, label: 'ÖPNV', path: '/transit', requiredModuleId: transitCeModuleId },
];

export default navItems;
