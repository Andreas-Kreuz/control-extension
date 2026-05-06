import LightControl from './LightControl';

function BlinkerLeftControl(props: { checked: boolean; onChange: (checked: boolean) => void }) {
  return <LightControl checked={props.checked} label="Blinker links" onChange={props.onChange} />;
}

export default BlinkerLeftControl;
