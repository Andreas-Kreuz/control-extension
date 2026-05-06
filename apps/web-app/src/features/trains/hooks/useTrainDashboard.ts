import {
  CommandEvent,
  PairingStatus,
  RollingStockAppDto,
  RollingStockRoom,
  RoomEvent,
  TrainAppDto,
} from '@ce/web-shared';
import { useMemo, useRef, useState, useEffect } from 'react';
import { useSocket } from '../../../app/hooks/useSocket';
import { useSocketIsConnected } from '../../../app/hooks/useSocketConnection';
import { useSocketPairingStatus } from '../../../app/hooks/useSocketPairing';
import { CameraControlSource } from '../../../shared/components/controls';
import useDebug from '../../../shared/socket/useDebug';
import useTransitSettings from '../../lines/hooks/useTransitSettings';
import {
  groupAxisByName,
  isSelectedRollingStock,
  mergeRollingStockModelInfo,
  MergedAxisGroup,
} from '../lib/trainDashboard';
import useOptimisticTrainControls from './useOptimisticTrainControls';
import useRollingStock from './useRollingStock';
import useSelectedScenario from './useSelectedScenario';
import useSetRollingStockCam from './useSetRollingStockCam';
import useSetTrainCam from './useSetTrainCam';
import useSetTrainCoupling from './useSetTrainCoupling';
import useSetTrainLight from './useSetTrainLight';
import useSetTrainSpeed from './useSetTrainSpeed';
import useTrainDynamic from './useTrainDynamic';
import useTrainRollingStock from './useTrainRollingStock';
import useTransitTrain from './useTransitTrain';
import { TrainDashboardPanelModel, TransitInfo } from '../lib/trainDashboardPanelModel';

const trainCameraSources: CameraControlSource[] = [
  { key: 3, label: 'Links oben' },
  { key: 4, label: 'Rechts oben' },
  { key: 8, label: 'Führerstand' },
  { key: -1, label: 'Front' },
  { key: -2, label: 'Front 2' },
  { key: 10, label: 'Kabine' },
];

function useTrainDashboard(): TrainDashboardPanelModel {
  const scenario = useSelectedScenario();
  const socket = useSocket();
  const setSpeed = useSetTrainSpeed();
  const setCoupling = useSetTrainCoupling();
  const setLight = useSetTrainLight();
  const setRollingStockCam = useSetRollingStockCam();
  const setTrainCam = useSetTrainCam();
  const debug = useDebug();
  const [selectionSource, setSelectionSource] = useState<'train' | 'rollingStock' | undefined>();
  const previousSelection = useRef<{ activeTrain: string; activeRollingStock: string }>({
    activeTrain: '',
    activeRollingStock: '',
  });
  const selectedTrainName = scenario?.activeTrain ?? '';
  const selectedRollingStockName = scenario?.activeRollingStock ?? '';
  const activeRollingStock = useRollingStock(selectedRollingStockName);
  const effectiveSelectionSource =
    selectionSource ?? (selectedRollingStockName ? 'rollingStock' : selectedTrainName ? 'train' : undefined);
  const trainId =
    effectiveSelectionSource === 'rollingStock'
      ? activeRollingStock && isSelectedRollingStock(activeRollingStock, selectedRollingStockName)
        ? activeRollingStock.trainName
        : ''
      : selectedTrainName;
  const train = useTrainDynamic(trainId);
  const rollingStock = useTrainRollingStock(trainId);
  const dynamicRollingStock = useTrainRollingStockDynamic(rollingStock ?? []);
  const transitTrain = useTransitTrain(trainId);
  const transitSettings = useTransitSettings();
  const cameraRollingStockName = rollingStock?.[0]?.name ?? activeRollingStock?.name ?? train?.name ?? trainId;
  const cameraRollingStock = useRollingStock(cameraRollingStockName);
  const trainRollingStock = useMemo(
    () =>
      rollingStock?.map((item) => mergeRollingStockModelInfo(item, dynamicRollingStock[item.id])) ?? [],
    [dynamicRollingStock, rollingStock],
  );
  const controls = useOptimisticTrainControls({
    train,
    onCouplingCommit: setCoupling,
    onLightCommit: setLight,
  });
  const canShowTrainAxes =
    trainRollingStock.length === 1 ||
    (trainRollingStock.length > 1 && trainRollingStock.every((item) => item.axisNamesKnown === true));
  const mergedAxisGroups = useMemo(
    () => (canShowTrainAxes ? groupAxisByName(trainRollingStock) : []),
    [canShowTrainAxes, trainRollingStock],
  );

  useEffect(() => {
    const currentSelection = {
      activeTrain: selectedTrainName,
      activeRollingStock: selectedRollingStockName,
    };
    const previous = previousSelection.current;
    previousSelection.current = currentSelection;

    setSelectionSource((currentSource) => {
      if (!previous.activeTrain && !previous.activeRollingStock) {
        return (
          currentSource ??
          (currentSelection.activeRollingStock ? 'rollingStock' : currentSelection.activeTrain ? 'train' : undefined)
        );
      }
      if (currentSelection.activeTrain && currentSelection.activeTrain !== previous.activeTrain) {
        return 'train';
      }
      if (currentSelection.activeRollingStock && currentSelection.activeRollingStock !== previous.activeRollingStock) {
        return 'rollingStock';
      }
      if (currentSelection.activeTrain && !currentSelection.activeRollingStock) {
        return 'train';
      }
      if (currentSelection.activeRollingStock && !currentSelection.activeTrain) {
        return 'rollingStock';
      }

      return currentSource;
    });
  }, [selectedRollingStockName, selectedTrainName]);

  if (!scenario?.activeRollingStock && !scenario?.activeTrain) {
    return { status: 'empty' };
  }

  if (!train) {
    return { status: 'loading' };
  }

  const transitNextStations = transitTrain?.nextStations ?? train.nextStations ?? [];
  const transit: TransitInfo | undefined =
    transitSettings &&
    (transitTrain?.line ||
      train.line ||
      transitTrain?.destination ||
      train.destination ||
      transitNextStations.length > 0)
      ? {
          line: transitTrain?.line ?? train.line ?? '-',
          destination: transitTrain?.destination ?? train.destination ?? '-',
          nextStations: transitNextStations,
        }
      : undefined;

  const changeCamera = (key: number) => {
    switch (key) {
      case -1:
      case -2: {
        if (debug) console.log('                 | CAM SET-', cameraRollingStockName, cameraRollingStock);
        setRollingStockCam(cameraRollingStock, key);
        setTrainCam(train.name, cameraRollingStockName, 9);
        break;
      }
      default: {
        setTrainCam(train.name, cameraRollingStockName, key);
      }
    }
  };

  const commitMergedAxis = (group: MergedAxisGroup, value: number) => {
    group.targets.forEach((target) => {
      socket.emit(CommandEvent.SetRollingStockAxis, {
        rollingStockName: target.rollingStockName,
        axisNumber: target.axisNumber,
        axisName: target.axisName,
        axisNamesKnown: target.axisNamesKnown,
        value,
      });
    });
  };

  return {
    cameraSources: trainCameraSources,
    canShowTrainAxes,
    controls,
    mergedAxisGroups,
    onCameraSelect: changeCamera,
    onMergedAxisCommit: commitMergedAxis,
    onSpeedCommit: (value) => setSpeed(train.name, value),
    rollingStock: trainRollingStock,
    selectedRollingStockName,
    selectedTrainName,
    status: 'ready',
    train,
    trainSelected: train.active || selectedTrainName === train.id || selectedTrainName === train.name,
    ...(transit !== undefined ? { transit } : {}),
  };
}

function useTrainRollingStockDynamic(rollingStock: RollingStockAppDto[]): Record<string, RollingStockAppDto> {
  const socket = useSocket();
  const isConnected = useSocketIsConnected();
  const pairingStatus = useSocketPairingStatus();
  const [dynamicRollingStock, setDynamicRollingStock] = useState<Record<string, RollingStockAppDto>>({});
  const rollingStockIds = useMemo(() => rollingStock.map((item) => item.id).filter(Boolean), [rollingStock]);
  const rollingStockIdsKey = rollingStockIds.join('\n');
  const canJoinRoom =
    isConnected && (pairingStatus === PairingStatus.Approved || pairingStatus === PairingStatus.Admin);

  useEffect(() => {
    const currentIds = new Set(rollingStockIds);
    setDynamicRollingStock((current) =>
      Object.fromEntries(Object.entries(current).filter(([id]) => currentIds.has(id))),
    );

    const handlers = rollingStockIds.map((id) => {
      const eventName = RollingStockRoom.eventId(id);
      const handler = (payload: string) => {
        const data = JSON.parse(payload) as RollingStockAppDto | null;
        setDynamicRollingStock((current) => {
          if (data) {
            return { ...current, [id]: data };
          }

          const next = { ...current };
          delete next[id];
          return next;
        });
      };

      socket.on(eventName, handler);
      return { eventName, handler, roomName: RollingStockRoom.roomId(id) };
    });

    if (canJoinRoom) {
      handlers.forEach((handler) => socket.emit(RoomEvent.JoinRoom, { room: handler.roomName }));
    }

    return () => {
      handlers.forEach((handler) => {
        socket.emit(RoomEvent.LeaveRoom, { room: handler.roomName });
        socket.off(handler.eventName, handler.handler);
      });
    };
  }, [canJoinRoom, rollingStockIdsKey, socket]);

  return dynamicRollingStock;
}

export default useTrainDashboard;
