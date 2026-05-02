import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import { ReactNode } from 'react';

export interface PlainCardProps {
  children?: ReactNode;
}

const PlainCard = (props: PlainCardProps) => {
  return <Card>{props.children}</Card>;
};

export default PlainCard;
