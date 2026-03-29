import { useSocket, useSocketIsConnected, useSocketPairingStatus } from './SocketProvider';
import { ApiDataRoom, PairingStatus, RoomEvent } from '@ak/web-shared';
import { DynamicRoom } from '@ak/web-shared';
import { useEffect, useRef, useState } from 'react';
import useDebug from './useDebug';

export function useDynamicRoomHandler(
  dynRoom: DynamicRoom,
  element: string,
  handler: (data: any) => any,
  cleanUpHandler?: () => void,
): void {
  return useRoomHandler(
    dynRoom.roomId(element),
    [{ eventName: dynRoom.eventId(element), handler: handler }],
    cleanUpHandler,
  );
}

export function useApiDataRoomHandler(apiName: string, handler: (data: any) => any, cleanUpHandler?: () => void): void {
  return useRoomHandler(
    ApiDataRoom.roomId(apiName),
    [{ eventName: ApiDataRoom.eventId(apiName), handler: handler }],
    cleanUpHandler,
  );
}

export function useRoomHandler(
  roomName: string,
  dataHandlers: { eventName: string; handler: (data: any) => any }[],
  cleanUpHandler?: () => void,
): void {
  const debug = useDebug();
  const socket = useSocket();
  const isConnected = useSocketIsConnected();
  const pairingStatus = useSocketPairingStatus();
  const count = useRef(0);
  count.current = count.current + 1;
  const myNr = count.current;
  const canJoinRoom =
    isConnected && (pairingStatus === PairingStatus.Approved || pairingStatus === PairingStatus.Admin);

  useEffect(() => {
    if (debug) console.log('REGISTER HANDLERS ❇️❇️❇️❇️❇️', roomName, myNr, 'ADD NEW HANDLERS');
    dataHandlers.forEach((h) => {
      if (debug) console.log('                 |❇️ On ------', roomName, myNr, 'ADD', h.eventName);
      // socket.off(h.eventName, h.handler);
      socket.on(h.eventName, h.handler);
    });

    return () => {
      if (debug) console.log('REMOVE HANDLERS  |❌❌❌❌❌', roomName, myNr, 'REMOVE ALL HANDLERS');
      if (debug) console.log('                 |➖ LEAVE ---', roomName, myNr, 'LEAVE ROOM');
      socket.emit(RoomEvent.LeaveRoom, { room: roomName });

      dataHandlers.forEach((h) => {
        if (debug) console.log('                 |❌ Off -----', roomName, myNr, 'REMOVE', h.eventName);
        socket.off(h.eventName, h.handler);
      });
      if (cleanUpHandler) cleanUpHandler();
    };
  }, [roomName]);

  useEffect(() => {
    if (!canJoinRoom) return;

    if (debug) console.log('                 |➕ JOIN ----', roomName, myNr, 'JOIN ROOM');
    socket.emit(RoomEvent.JoinRoom, { room: roomName });
  }, [canJoinRoom, roomName, socket]);
}
