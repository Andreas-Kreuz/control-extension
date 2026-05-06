import LightControl from './LightControl';

function BlinkerRightControl(props: { checked: boolean; onChange: (checked: boolean) => void }) {
  return <LightControl checked={props.checked} label="Blinker rechts" onChange={props.onChange} />;
}

export default BlinkerRightControl;
