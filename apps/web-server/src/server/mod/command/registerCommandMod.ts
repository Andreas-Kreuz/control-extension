import SocketService from '../../clientio/SocketService';
import EepService from '../../eep/service/EepService';
import { CommandEvent, RoomEvent } from '@ce/web-shared';
import { Server, Socket } from 'socket.io';

export const registerCommandMod = (
  _io: Server,
  socketService: SocketService,
  eepService: EepService,
  _debug: boolean,
) => {
  const queueCommand = eepService.queueCommand;
  const socketConnected = (socket: Socket) => {
    socket.on(RoomEvent.JoinRoom, (rooms: { room: string }) => {
      if (!socketService.ensureApprovedSocket(socket, rooms.room)) {
        return;
      }
      if (rooms.room === CommandEvent.Room) {
        // Nothing to do here!
      }
    });

    socket.on(CommandEvent.ChangeCamToStatic, (action: { staticCam: string }) => {
      if (!socketService.ensureApprovedSocket(socket, CommandEvent.ChangeCamToStatic)) {
        return;
      }
      const command = 'EEPSetCamera|0|' + action.staticCam;
      queueCommand(command);
    });

    socket.on(CommandEvent.ChangeCamToTrain, (action: { trainName: string; rollingStockName: string; id?: number }) => {
      if (!socketService.ensureApprovedSocket(socket, CommandEvent.ChangeCamToTrain)) {
        return;
      }
      if (action.id === 8 || action.id === 9 || action.id === 10) {
        queueCommand('EEPSetTrainActive|' + action.trainName);
        queueCommand('EEPRollingstockSetActive|' + action.rollingStockName);
      }
      const camId = action.id ? action.id : 9;
      const command = 'EEPSetPerspectiveCamera|' + camId + '|' + action.trainName;
      queueCommand(command);
    });

    socket.on(
      CommandEvent.ChangeCamToRollingStock,
      (action: {
        rollingStock: string;
        posX: number;
        posY: number;
        posZ: number;
        redH: number;
        redV: number;
        activate: number;
      }) => {
        if (!socketService.ensureApprovedSocket(socket, CommandEvent.ChangeCamToRollingStock)) {
          return;
        }
        queueCommand('EEPRollingstockSetActive|' + action.rollingStock);
        const command =
          'EEPRollingstockSetUserCamera|' +
          action.rollingStock +
          '|' +
          action.posX +
          '|' +
          action.posY +
          '|' +
          action.posZ +
          '|' +
          action.redH +
          '|' +
          action.redV +
          '|' +
          action.activate;
        queueCommand(command);
      },
    );

    socket.on(CommandEvent.ChangeSetting, (action: { name: string; func: string; newValue: unknown }) => {
      if (!socketService.ensureApprovedSocket(socket, CommandEvent.ChangeSetting)) {
        return;
      }
      const command = action.func + '|' + action.newValue;
      queueCommand(command);
    });

    socket.on(
      CommandEvent.SetRollingStockAxis,
      (action: { rollingStockName: string; axisNumber: number; value: number }) => {
        if (!socketService.ensureApprovedSocket(socket, CommandEvent.SetRollingStockAxis)) {
          return;
        }

        const axisNumber = Math.round(Number(action.axisNumber));
        const value = Math.min(100, Math.max(0, Math.round(Number(action.value))));
        if (!action.rollingStockName || !Number.isFinite(axisNumber) || !Number.isFinite(value)) {
          return;
        }

        const command = 'EEPRollingstockSetAxisByNumber|' + action.rollingStockName + '|' + axisNumber + '|' + value;
        queueCommand(command);
      },
    );

    socket.on(CommandEvent.SetTrainSpeed, (action: { trainName: string; speed: number }) => {
      if (!socketService.ensureApprovedSocket(socket, CommandEvent.SetTrainSpeed)) {
        return;
      }

      const speed = Math.min(250, Math.max(-250, Math.round(Number(action.speed))));
      if (!action.trainName || !Number.isFinite(speed)) {
        return;
      }

      queueCommand('EEPSetTrainSpeed|' + action.trainName + '|' + speed + '|true');
    });

    socket.on(
      CommandEvent.SetTrainCoupling,
      (action: { trainName: string; position: 'front' | 'rear'; enabled: boolean }) => {
        if (!socketService.ensureApprovedSocket(socket, CommandEvent.SetTrainCoupling)) {
          return;
        }
        if (!action.trainName || (action.position !== 'front' && action.position !== 'rear')) {
          return;
        }

        const commandName = action.position === 'front' ? 'EEPSetTrainCouplingFront' : 'EEPSetTrainCouplingRear';
        queueCommand(commandName + '|' + action.trainName + '|' + (action.enabled === true));
      },
    );

    socket.on(CommandEvent.SetTrainLight, (action: { trainName: string; source: number; enabled: boolean }) => {
      if (!socketService.ensureApprovedSocket(socket, CommandEvent.SetTrainLight)) {
        return;
      }

      const source = Math.round(Number(action.source));
      if (!action.trainName || !Number.isFinite(source) || source < 0 || source > 3) {
        return;
      }

      queueCommand('EEPSetTrainLight|' + action.trainName + '|' + (action.enabled === true) + '|' + source);
    });
  };

  socketService.addOnSocketConnectedCallback((socket: Socket) => socketConnected(socket));
};
