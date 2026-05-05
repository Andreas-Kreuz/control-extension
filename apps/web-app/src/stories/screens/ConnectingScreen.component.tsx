import Box from '@mui/material/Box';
import MyConnectingScreen, {
  ConnectingScreenProps as MyConnectingScreenProps,
} from '../../app/components/ConnectingScreen';

export type ConnectingScreenProps = Omit<MyConnectingScreenProps, 'children'>;

export const ConnectingScreen = ({ ...args }: ConnectingScreenProps) => (
  <Box sx={{ minHeight: '20rem' }}>
    <MyConnectingScreen {...args} />
  </Box>
);

export default ConnectingScreen;
