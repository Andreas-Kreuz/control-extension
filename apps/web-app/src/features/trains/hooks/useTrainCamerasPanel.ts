import useDebug from '../../../shared/socket/useDebug';
import { TrainCameraItem } from '../components/panels/TrainCamsPanel';
import useRollingStock from './useRollingStock';
import useRollingStockDynamic from './useRollingStockDynamic';
import useSetRollingStockCam from './useSetRollingStockCam';
import useSetTrainCam from './useSetTrainCam';

const cameraData: readonly TrainCameraItem[] = [
  { key: 3, label: 'Links oben' },
  { key: 4, label: 'Rechts oben' },
  { key: 8, label: 'Führerstand' },
  { key: -1, label: 'Front' },
  { key: -2, label: 'Front 2' },
  { key: 10, label: 'Kabine' },
];

function useTrainCamerasPanel(trainName: string, rollingStockName: string) {
  const rollingStock = useRollingStock(rollingStockName);
  const rollingStockDynamic = useRollingStockDynamic(rollingStockName);
  const setRollingStockCam = useSetRollingStockCam();
  const setTrainCam = useSetTrainCam();
  const debug = useDebug();
  void rollingStockDynamic;

  const onCameraSelect = (key: number) => {
    switch (key) {
      case -1:
      case -2: {
        if (debug) console.log('                 |📹 CAM SET-', rollingStockName, rollingStock);
        setRollingStockCam(rollingStock, key);
        setTrainCam(trainName, rollingStockName, 9);
        break;
      }
      default: {
        setTrainCam(trainName, rollingStockName, key);
      }
    }
  };

  return { cameras: cameraData, onCameraSelect };
}

export default useTrainCamerasPanel;
