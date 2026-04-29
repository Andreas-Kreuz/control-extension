import { CommandEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';

function useSetTrainCoupling() {
  const socket = useSocket();

  return (trainName: string, position: 'front' | 'rear', enabled: boolean) => {
    socket.emit(CommandEvent.SetTrainCoupling, { trainName, position, enabled });
  };
}

export default useSetTrainCoupling;
