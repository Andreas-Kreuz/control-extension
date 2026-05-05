import LightControl from './LightControl';

function DrivingLightControl(props: { checked: boolean; onChange: (checked: boolean) => void }) {
  return <LightControl checked={props.checked} label="Fahrlicht" onChange={props.onChange} />;
}

export default DrivingLightControl;
