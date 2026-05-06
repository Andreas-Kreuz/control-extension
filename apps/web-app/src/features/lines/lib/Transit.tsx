import { getLineColor, getLineIcon } from '../../../shared/components/lines/LineAvatar';

export const getIcon = (trafficType: string) => {
  return getLineIcon(trafficType);
};

export const getColor = (trafficType: string) => {
  return getLineColor(trafficType);
};
