import MyImageCard, { ImageCardProps as MyImageCardProps } from '../../shared/components/cards/ImageCard';
import { BrowserRouter } from 'react-router-dom';

export interface ImageCardProps extends MyImageCardProps {
  label: string;
}

export const ImageCard = ({ label, ...rest }: ImageCardProps) => (
  <BrowserRouter>
    <MyImageCard {...rest}></MyImageCard>
  </BrowserRouter>
);
