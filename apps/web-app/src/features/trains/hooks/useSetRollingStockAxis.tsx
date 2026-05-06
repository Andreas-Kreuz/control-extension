import { CommandEvent, RollingStockAppDto } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';

function useSetRollingStockAxis() {
  const socket = useSocket();

  return (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => {
    socket.emit(CommandEvent.SetRollingStockAxis, {
      rollingStockName: rollingStock.name,
      axisNumber,
      axisName: rollingStock.axisNames?.[String(axisNumber)],
      axisNamesKnown: rollingStock.axisNamesKnown,
      value,
    });
  };
}

export default useSetRollingStockAxis;
