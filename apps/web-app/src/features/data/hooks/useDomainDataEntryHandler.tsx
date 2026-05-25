import { CeTypeRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

const noopRoom = new CeTypeRoom('__noop__');

function useDomainDataEntryHandler(
  ceType: string | undefined,
  entryId: string,
  handler: (payload: string) => void,
  cleanUpHandler?: () => void,
): void {
  useDomainRoomHandler(ceType ? new CeTypeRoom(ceType) : noopRoom, entryId, handler, cleanUpHandler);
}

export default useDomainDataEntryHandler;
