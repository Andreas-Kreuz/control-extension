import { CommandEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';

function useSetTrainSpeed() {
  const socket = useSocket();

  return (trainName: string, speed: number) => {
    socket.emit(CommandEvent.SetTrainSpeed, { trainName, speed });
  };
}

export default useSetTrainSpeed;
