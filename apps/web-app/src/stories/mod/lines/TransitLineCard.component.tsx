import MyTransitLineCard, {
  TransitLineCardProps as MyTransitLineCardProps,
} from '../../../features/lines/components/TransitLineCard';
import { BrowserRouter } from 'react-router-dom';

export type TransitLineCardProps = MyTransitLineCardProps;

export const TransitLineCard = (props: TransitLineCardProps) => (
  <BrowserRouter>
    <MyTransitLineCard {...props} />
  </BrowserRouter>
);
