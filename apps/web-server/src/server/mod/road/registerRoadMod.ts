import SocketService from '../../clientio/SocketService';
import EepService from '../../eep/service/EepService';
import { RoadEvent, RoomEvent } from '@ce/web-shared';
import type { AlignStructureSignalInstallerCommandAppDto } from '@ce/web-shared';
import { Socket, Server } from 'socket.io';

const validHousingKinds = new Set([
  'HOUSING_1',
  'HOUSING_2',
  'HOUSING_3',
  'HOUSING_4',
  'HOUSING_5',
  'MAST_1',
  'MAST_2',
  'MAST_3',
  'MAST_4',
  'MAST_5',
  'MAST_LEFT_1',
  'MAST_LEFT_2',
  'MAST_LEFT_3',
  'MAST_LEFT_4',
  'MAST_LEFT_5',
  'MAST_RIGHT_1',
  'MAST_RIGHT_2',
  'MAST_RIGHT_3',
  'MAST_RIGHT_4',
  'MAST_RIGHT_5',
]);

function isSafeCommandText(value: unknown): value is string {
  return typeof value === 'string' && value.trim().length > 0 && !/[|\r\n]/.test(value);
}

function isFiniteNumber(value: unknown): value is number {
  return typeof value === 'number' && Number.isFinite(value);
}

function isValidTarget(target: unknown): target is AlignStructureSignalInstallerCommandAppDto['targets'][number] {
  if (!target || typeof target !== 'object') return false;
  const candidate = target as Partial<AlignStructureSignalInstallerCommandAppDto['targets'][number]>;
  return (
    isSafeCommandText(candidate.name) &&
    isFiniteNumber(candidate.posX) &&
    isFiniteNumber(candidate.posY) &&
    isFiniteNumber(candidate.posZ) &&
    isFiniteNumber(candidate.rotX) &&
    isFiniteNumber(candidate.rotY) &&
    isFiniteNumber(candidate.rotZ)
  );
}

function isAlignStructureSignalInstallerCommand(action: unknown): action is AlignStructureSignalInstallerCommandAppDto {
  if (!action || typeof action !== 'object') return false;
  const candidate = action as Partial<AlignStructureSignalInstallerCommandAppDto>;
  return (
    validHousingKinds.has(candidate.housingKind ?? '') &&
    isSafeCommandText(candidate.housingName) &&
    isSafeCommandText(candidate.housingTag) &&
    candidate.housingTag.length <= 1024 &&
    Array.isArray(candidate.signals) &&
    candidate.signals.length <= 5 &&
    candidate.signals.every(isSafeCommandText) &&
    (candidate.blendName === undefined || isSafeCommandText(candidate.blendName)) &&
    Array.isArray(candidate.targets) &&
    candidate.targets.length <= 6 &&
    candidate.targets.every(isValidTarget)
  );
}

export const registerRoadMod = (_io: Server, socketService: SocketService, eepService: EepService, _debug: boolean) => {
  const queueCommand = eepService.queueCommand;

  function socketConnected(socket: Socket) {
    socket.on(RoomEvent.JoinRoom, (rooms: { room: string }) => {
      if (!socketService.ensureApprovedSocket(socket, rooms.room)) {
        return;
      }
      if (rooms.room === RoadEvent.Room) {
        // Nothing to do here!
      }
    });

    socket.on(RoadEvent.SwitchAutomatically, (action: { intersectionName: string }) => {
      if (!socketService.ensureApprovedSocket(socket, RoadEvent.SwitchAutomatically)) {
        return;
      }
      const command = 'AkKreuzungSchalteAutomatisch|' + action.intersectionName;
      queueCommand(command);
    });
    socket.on(RoadEvent.SwitchManually, (action: { intersectionName: string; phaseName: string }) => {
      if (!socketService.ensureApprovedSocket(socket, RoadEvent.SwitchManually)) {
        return;
      }
      const command = 'AkKreuzungSchalteManuell|' + action.intersectionName + '|' + action.phaseName;
      queueCommand(command);
    });

    socket.on(RoadEvent.AlignStructureSignalInstaller, (action: unknown) => {
      if (!socketService.ensureApprovedSocket(socket, RoadEvent.AlignStructureSignalInstaller)) {
        return;
      }
      if (!isAlignStructureSignalInstallerCommand(action)) {
        return;
      }

      action.targets.forEach((target) => {
        queueCommand(`EEPStructureSetPosition|${target.name}|${target.posX}|${target.posY}|${target.posZ}`);
        queueCommand(`EEPStructureSetRotation|${target.name}|${target.rotX}|${target.rotY}|${target.rotZ}`);
      });
      queueCommand(`EEPStructureSetTagText|${action.housingName}|${action.housingTag}`);
    });
  }

  socketService.addOnSocketConnectedCallback((socket: Socket) => socketConnected(socket));
};
