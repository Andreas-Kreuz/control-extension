import { RollingStockAppDto, TrainAppDto } from '@ce/web-shared';
import { CameraControlSource } from '../../../shared/components/controls';
import { MergedAxisGroup } from './trainDashboard';

export type TrainDashboardControlsModel = {
  couplingFront: number;
  couplingRear: number;
  lights: Record<string, boolean>;
  onCouplingChange: (side: 'front' | 'rear', checked: boolean) => void;
  onLightChange: (source: number, checked: boolean) => void;
};

export type TransitInfo = {
  line: string;
  destination: string;
  nextStations: NonNullable<TrainAppDto['nextStations']>;
};

export type TrainDashboardPanelModel =
  | { status: 'empty' }
  | { status: 'loading' }
  | {
      cameraSources: CameraControlSource[];
      canShowTrainAxes: boolean;
      controls: TrainDashboardControlsModel;
      licencePlates: string[];
      mergedAxisGroups: MergedAxisGroup[];
      onCameraSelect: (key: number) => void;
      onMergedAxisCommit: (group: MergedAxisGroup, value: number) => void;
      onSpeedCommit: (value: number) => void;
      rollingStock: RollingStockAppDto[];
      selectedRollingStockName: string;
      selectedTrainName: string;
      status: 'ready';
      train: TrainAppDto;
      trainSelected: boolean;
      transit?: TransitInfo;
      vehicleNumbers: string[];
    };
