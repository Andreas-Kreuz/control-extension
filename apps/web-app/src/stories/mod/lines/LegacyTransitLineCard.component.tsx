import MyLegacyTransitLineCard, {
  LegacyTransitLineCardProps as MyLegacyTransitLineCardProps,
} from '../../../features/lines/components/LegacyTransitLineCard';
import { Box } from '@mui/material';
import { BrowserRouter } from 'react-router-dom';

export type LegacyTransitLineCardProps = Omit<MyLegacyTransitLineCardProps, 'children'>;

export const LegacyTransitLineCard = ({ ...rest }: LegacyTransitLineCardProps) => (
  <BrowserRouter>
    <MyLegacyTransitLineCard {...rest}>
      <Box p={2}>Hello World</Box>
    </MyLegacyTransitLineCard>
  </BrowserRouter>
);
