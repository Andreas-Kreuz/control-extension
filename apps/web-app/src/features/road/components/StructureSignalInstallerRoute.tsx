import { useMemo, useState } from 'react';
import type { AlignStructureSignalInstallerCommandAppDto, StructureAppDto } from '@ce/web-shared';
import { CeTypes, RoadEvent } from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import StructureSignalInstaller from './structure-signal-installer/StructureSignalInstaller';

function StructureSignalInstallerRoute() {
  const socket = useSocket();
  const [structuresById, setStructuresById] = useState<Record<string, StructureAppDto>>({});
  const structures = useMemo(
    () => Object.values(structuresById).sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true })),
    [structuresById],
  );

  useApiDataRoomHandler(CeTypes.HubStructure, (payload: string) => {
    setStructuresById(JSON.parse(payload) as Record<string, StructureAppDto>);
  });

  function alignStructures(command: AlignStructureSignalInstallerCommandAppDto) {
    socket.emit(RoadEvent.AlignStructureSignalInstaller, command);
  }

  return (
    <PageContainer>
      <PageHeadline>Ampelaufsteller</PageHeadline>
      <StructureSignalInstaller structures={structures} onAlign={alignStructures} />
    </PageContainer>
  );
}

export default StructureSignalInstallerRoute;
