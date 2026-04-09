import MyAppCardImg, { AppCardImgProps as MyAppCardProps } from '../../shared/components/AppCardImg';
import { BrowserRouter } from 'react-router-dom';

export interface AppCardImgProps extends MyAppCardProps {
  label: string;
}

export const AppCardImg = ({ label, ...rest }: AppCardImgProps) => (
  <BrowserRouter>
    <MyAppCardImg {...rest}></MyAppCardImg>
  </BrowserRouter>
);
