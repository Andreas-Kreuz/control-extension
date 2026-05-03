import MyBackgroundImageCard, {
  BackgroundImageCardProps as MyBackgroundImageCardProps,
} from '../../shared/components/cards/BackgroundImageCard';
import { BrowserRouter } from 'react-router-dom';

export type BackgroundImageCardProps = MyBackgroundImageCardProps;

const Template = (args: BackgroundImageCardProps) => (
  <BrowserRouter>
    <MyBackgroundImageCard {...args}></MyBackgroundImageCard>
  </BrowserRouter>
);

export const BackgroundImageCard = Template.bind({});
