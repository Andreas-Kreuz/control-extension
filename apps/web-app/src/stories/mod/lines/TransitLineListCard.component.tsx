import MyTransitLineListCard, {
  TransitLineListCardProps as MyTransitLineListCardProps,
} from '../../../features/lines/components/TransitLineListCard';
import { BrowserRouter } from 'react-router-dom';

export type TransitLineListCardProps = MyTransitLineListCardProps;

export const TransitLineListCard = (props: TransitLineListCardProps) => (
  <BrowserRouter>
    <MyTransitLineListCard {...props} />
  </BrowserRouter>
);
