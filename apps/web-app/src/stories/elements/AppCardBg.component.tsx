import MyAppCardBg, { AppCardBgProps as MyAppCardProps } from '../../components/AppCardBg';
import { BrowserRouter } from 'react-router-dom';

export type AppCardBgProps = MyAppCardProps;

const Template = (args: AppCardBgProps) => (
  <BrowserRouter>
    <MyAppCardBg {...args}></MyAppCardBg>
  </BrowserRouter>
);

export const AppCardBg = Template.bind({});
