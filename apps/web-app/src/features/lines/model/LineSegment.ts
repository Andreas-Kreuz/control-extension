import StationInfo from './StationInfo';

export default interface LineSegment {
  id: string; // the route name
  destination: string;
  routeName: string;
  stations: StationInfo[];
}
