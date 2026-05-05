import LightControl from './LightControl';

function BrakeLightControl(props: { checked: boolean; onChange: (checked: boolean) => void }) {
  return <LightControl checked={props.checked} label="Bremslicht" onChange={props.onChange} />;
}

export default BrakeLightControl;
