import Stack from '@mui/material/Stack';
import {
  BlinkerLeftControl,
  BlinkerRightControl,
  BrakeLightControl,
  CameraControlSource,
  ControlGrid,
  CouplingControl,
  DrivingLightControl,
} from '../../../../shared/components/controls';
import TrainCamsPanel from './TrainCamsPanel';

function TrainControlsPanel(props: {
  cameraSources: CameraControlSource[];
  couplingFront: number;
  couplingRear: number;
  lights: Record<string, boolean>;
  onCameraSelect: (key: number) => void;
  onCouplingChange: (side: 'front' | 'rear', checked: boolean) => void;
  onLightChange: (source: number, checked: boolean) => void;
}) {
  return (
    <Stack spacing={2}>
      <ControlGrid>
        <CouplingControl
          value={props.couplingFront}
          disabled={props.couplingFront === 0}
          label="Kupplung vorne"
          onChange={(checked) => props.onCouplingChange('front', checked)}
        />
        <CouplingControl
          value={props.couplingRear}
          disabled={props.couplingRear === 0}
          label="Kupplung hinten"
          onChange={(checked) => props.onCouplingChange('rear', checked)}
        />
        <DrivingLightControl checked={props.lights?.['0'] === true} onChange={(checked) => props.onLightChange(0, checked)} />
        <BrakeLightControl checked={props.lights?.['3'] === true} onChange={(checked) => props.onLightChange(3, checked)} />
        <BlinkerLeftControl checked={props.lights?.['1'] === true} onChange={(checked) => props.onLightChange(1, checked)} />
        <BlinkerRightControl checked={props.lights?.['2'] === true} onChange={(checked) => props.onLightChange(2, checked)} />
      </ControlGrid>
      <TrainCamsPanel cameras={props.cameraSources} onCameraSelect={props.onCameraSelect} />
    </Stack>
  );
}

export default TrainControlsPanel;
