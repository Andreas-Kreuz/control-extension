import LineSegment from './LineSegment';
import type { LineTrafficType } from '../../../shared/components/lines/LineAvatar';

export default interface Line {
  id: number;
  nr: string;
  trafficType: LineTrafficType;
  lineSegments: LineSegment[];
}
