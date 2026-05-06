import useTrainCamerasPanel from '../hooks/useTrainCamerasPanel';
import TrainCamsPanel from './panels/TrainCamsPanel';

function TrainCamerasSection(props: { trainName: string; rollingStockName: string }) {
  const cameraPanel = useTrainCamerasPanel(props.trainName, props.rollingStockName);

  return <TrainCamsPanel cameras={cameraPanel.cameras} onCameraSelect={cameraPanel.onCameraSelect} />;
}

export default TrainCamerasSection;
