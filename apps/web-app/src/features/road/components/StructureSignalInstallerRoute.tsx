import { useCallback, useMemo, useState } from 'react';
import type {
  AlignStructureSignalInstallerCommandAppDto,
  FocusStructureSignalInstallerCameraCommandAppDto,
  StructureAppDto,
} from '@ce/web-shared';
import { CeTypes, RoadEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';
import useDomainDataEntryHandler from '../../data/hooks/useDomainDataEntryHandler';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import StructureSignalInstaller from './structure-signal-installer/StructureSignalInstaller';

function StructureSignalInstallerRoute() {
  const socket = useSocket();
  const [structuresById, setStructuresById] = useState<Record<string, StructureAppDto>>({});
  const [selectedHousingId, setSelectedHousingId] = useState('');
  const structures = useMemo(
    () => Object.values(structuresById).sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true })),
    [structuresById],
  );

  useApiDataRoomHandler(CeTypes.HubStructure, (payload: string) => {
    setStructuresById(JSON.parse(payload) as Record<string, StructureAppDto>);
  });

  useDomainDataEntryHandler(
    selectedHousingId ? CeTypes.HubStructure : undefined,
    selectedHousingId || 'none',
    (payload) => {
      const structure = JSON.parse(payload) as StructureAppDto | null;
      if (!structure?.id) return;
      setStructuresById((current) => ({ ...current, [structure.id]: structure }));
    },
  );

  const changeSelectedHousing = useCallback((housingId: string) => {
    setSelectedHousingId(housingId);
  }, []);

  function alignStructures(command: AlignStructureSignalInstallerCommandAppDto) {
    socket.emit(RoadEvent.AlignStructureSignalInstaller, command);
  }

  function focusCamera(command: FocusStructureSignalInstallerCameraCommandAppDto) {
    socket.emit(RoadEvent.FocusStructureSignalInstallerCamera, command);
  }

  return (
    <PageContainer>
      <PageHeadline>Ampelaufsteller</PageHeadline>
      <StructureSignalInstaller
        structures={structures}
        onAlign={alignStructures}
        onFocusCamera={focusCamera}
        onHousingSelectionChange={changeSelectedHousing}
      />
    </PageContainer>
  );
}

export default StructureSignalInstallerRoute;
