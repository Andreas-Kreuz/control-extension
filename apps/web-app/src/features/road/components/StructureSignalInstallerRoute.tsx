import { useCallback, useMemo, useState } from 'react';
import type {
  AlignStructureSignalInstallerCommandAppDto,
  FocusStructureSignalInstallerCameraCommandAppDto,
  StructureAppDto,
} from '@ce/web-shared';
import { CeTypeRoom, CeTypes, DomainRoom, RoadEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import { useApiDataRoomHandler, useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import StructureSignalInstaller from './structure-signal-installer/StructureSignalInstaller';

const structureRoom = new CeTypeRoom(CeTypes.HubStructure);
const noopRoom = new DomainRoom('__noop__');

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

  useDomainRoomHandler(selectedHousingId ? structureRoom : noopRoom, selectedHousingId || 'none', (payload: string) => {
    const structure = JSON.parse(payload) as StructureAppDto | null;
    if (!structure?.id) return;
    setStructuresById((current) => ({ ...current, [structure.id]: structure }));
  });

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
