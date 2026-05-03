import MyPlainCard, { PlainCardProps as MyPlainCardProps } from '../../shared/components/cards/PlainCard';
import { Box } from '@mui/material';
import { BrowserRouter } from 'react-router-dom';

export type PlainCardProps = Omit<MyPlainCardProps, 'children'>;

export const PlainCard = ({ ...rest }: PlainCardProps) => (
  <BrowserRouter>
    <MyPlainCard {...rest}>
      <Box sx={{ p: 2 }}>Hello World</Box>
    </MyPlainCard>
  </BrowserRouter>
);
