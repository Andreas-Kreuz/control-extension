import MyAppCardImg, { AppCardImgProps as MyAppCardProps } from '../../shared/ui/AppCardImg';
import { BrowserRouter } from 'react-router-dom';

export interface AppCardImgProps extends MyAppCardProps {
  label: string;
}

export const AppCardImg = ({ label, ...rest }: AppCardImgProps) => (
  <BrowserRouter>
    <MyAppCardImg {...rest}></MyAppCardImg>
  </BrowserRouter>
);
