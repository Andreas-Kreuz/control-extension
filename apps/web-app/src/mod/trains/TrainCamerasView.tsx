import TrainCamList from './TrainCamList';

function TrainCamerasView(props: { trainName: string; rollingStockName: string }) {
  return <TrainCamList trainName={props.trainName} rollingStockName={props.rollingStockName} />;
}

export default TrainCamerasView;
