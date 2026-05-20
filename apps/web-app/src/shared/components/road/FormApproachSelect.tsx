import type { IntersectionWizardApproach } from '@ce/web-shared';
import Approach, { approaches } from './Approach';
import FormSelect from './FormSelect';

function FormApproachSelect(props: {
  errorTexts?: string[];
  id: string;
  infoText?: string;
  onChange: (value: IntersectionWizardApproach) => void;
  value: IntersectionWizardApproach;
}) {
  return (
    <FormSelect
      id={props.id}
      label="Zufahrt aus"
      value={props.value}
      onChange={props.onChange}
      infoText={props.infoText}
      errorTexts={props.errorTexts}
      renderValue={(value) => <Approach approach={value} />}
      options={approaches.map((approach) => ({
        value: approach,
        label: <Approach approach={approach} />,
      }))}
    />
  );
}

export default FormApproachSelect;
