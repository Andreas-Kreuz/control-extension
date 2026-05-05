import { CommandEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';

function useSetTrainLight() {
  const socket = useSocket();

  return (trainName: string, source: number, enabled: boolean) => {
    socket.emit(CommandEvent.SetTrainLight, { trainName, source, enabled });
  };
}

export default useSetTrainLight;
