import { TrainAppDto } from '@ce/web-shared';
import { useEffect, useState } from 'react';

const optimisticSwitchTimeoutMs = 5000;

type OptimisticSwitchState = {
  trainName: string;
  couplingFront?: { value: number; changedAt: number };
  couplingRear?: { value: number; changedAt: number };
  lights: Record<string, { value: boolean; changedAt: number }>;
};

function useOptimisticTrainControls(props: {
  onCouplingCommit: (trainName: string, side: 'front' | 'rear', checked: boolean) => void;
  onLightCommit: (trainName: string, source: number, checked: boolean) => void;
  train: TrainAppDto | undefined;
}) {
  const { train } = props;
  const [couplingFront, setCouplingFront] = useState(train?.couplingFront ?? 0);
  const [couplingRear, setCouplingRear] = useState(train?.couplingRear ?? 0);
  const [lights, setLights] = useState<Record<string, boolean>>(train?.lights ?? {});
  const [optimisticState, setOptimisticState] = useState<OptimisticSwitchState>({
    trainName: train?.name ?? '',
    lights: {},
  });

  useEffect(() => {
    if (!train) {
      return;
    }

    const now = Date.now();
    setOptimisticState((previous) => {
      if (previous.trainName !== train.name) {
        setCouplingFront(train.couplingFront);
        setCouplingRear(train.couplingRear);
        setLights(train.lights ?? {});
        return { trainName: train.name, lights: {} };
      }

      const nextOptimisticState: OptimisticSwitchState = {
        trainName: train.name,
        lights: Object.fromEntries(
          Object.entries(previous.lights).filter(
            ([source, optimisticLight]) =>
              train.lights?.[source] !== optimisticLight.value &&
              now - optimisticLight.changedAt < optimisticSwitchTimeoutMs,
          ),
        ),
      };
      if (
        previous.couplingFront &&
        train.couplingFront !== previous.couplingFront.value &&
        now - previous.couplingFront.changedAt < optimisticSwitchTimeoutMs
      ) {
        nextOptimisticState.couplingFront = previous.couplingFront;
      }
      if (
        previous.couplingRear &&
        train.couplingRear !== previous.couplingRear.value &&
        now - previous.couplingRear.changedAt < optimisticSwitchTimeoutMs
      ) {
        nextOptimisticState.couplingRear = previous.couplingRear;
      }

      setCouplingFront(nextOptimisticState.couplingFront?.value ?? train.couplingFront);
      setCouplingRear(nextOptimisticState.couplingRear?.value ?? train.couplingRear);
      setLights({
        ...(train.lights ?? {}),
        ...Object.fromEntries(
          Object.entries(nextOptimisticState.lights).map(([source, optimisticLight]) => [
            source,
            optimisticLight.value,
          ]),
        ),
      });

      return nextOptimisticState;
    });
  }, [train]);

  const changeCoupling = (side: 'front' | 'rear', checked: boolean) => {
    if (!train) {
      return;
    }

    const value = checked ? 1 : 2;
    if (side === 'front') {
      setCouplingFront(value);
      setOptimisticState((previous) => ({
        ...previous,
        trainName: train.name,
        couplingFront: { value, changedAt: Date.now() },
      }));
    } else {
      setCouplingRear(value);
      setOptimisticState((previous) => ({
        ...previous,
        trainName: train.name,
        couplingRear: { value, changedAt: Date.now() },
      }));
    }
    props.onCouplingCommit(train.name, side, checked);
  };

  const changeLight = (source: number, checked: boolean) => {
    if (!train) {
      return;
    }

    const sourceKey = String(source);
    setLights((previous) => ({
      ...previous,
      [sourceKey]: checked,
    }));
    setOptimisticState((previous) => ({
      ...previous,
      trainName: train.name,
      lights: {
        ...previous.lights,
        [sourceKey]: { value: checked, changedAt: Date.now() },
      },
    }));
    props.onLightCommit(train.name, source, checked);
  };

  return {
    couplingFront,
    couplingRear,
    lights,
    onCouplingChange: changeCoupling,
    onLightChange: changeLight,
  };
}

export default useOptimisticTrainControls;
