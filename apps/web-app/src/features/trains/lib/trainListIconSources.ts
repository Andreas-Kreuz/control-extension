import { TrainType } from '@ce/web-shared';

export type TrainListIconSources = Record<TrainType, string>;

export const ListIconSources: TrainListIconSources = {
  [TrainType.Bike]: '/assets/traffic-icons/vehicle-bicycle.svg',
  [TrainType.Boat]: '/assets/traffic-icons/vehicle-ship.svg',
  [TrainType.Bus]: '/assets/traffic-icons/vehicle-bus.svg',
  [TrainType.Car]: '/assets/traffic-icons/vehicle-passenger-car.svg',
  [TrainType.CarWithTrailer]: '/assets/traffic-icons/vehicle-passenger-car-with-trailer.svg',
  [TrainType.Motorcycle]: '/assets/traffic-icons/vehicle-motorbike.svg',
  [TrainType.Plane]: '/assets/traffic-icons/vehicle-plane.svg',
  [TrainType.TrainDiesel]: '/assets/traffic-icons/vehicle-train.svg',
  [TrainType.TrainElectric]: '/assets/traffic-icons/vehicle-train.svg',
  [TrainType.TrainSteam]: '/assets/traffic-icons/vehicle-train-steam.svg',
  [TrainType.TrainMetro]: '/assets/traffic-icons/vehicle-train.svg',
  [TrainType.Tram]: '/assets/traffic-icons/vehicle-tram.svg',
  [TrainType.Truck]: '/assets/traffic-icons/vehicle-truck.svg',
  [TrainType.TruckWithTrailer]: '/assets/traffic-icons/vehicle-truck-with-trailer.svg',
};
