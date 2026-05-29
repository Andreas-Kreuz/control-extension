import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { DataTransferFieldsAppDto, DataTransferFieldsRoom } from '@ce/web-shared';

function useDataTransferFields(ceType: string): DataTransferFieldsAppDto {
  const [fields, setFields] = useState<DataTransferFieldsAppDto>({ ceType, fields: [] });

  useDomainRoomHandler(
    DataTransferFieldsRoom,
    ceType,
    (payload: string) => {
      setFields(JSON.parse(payload));
    },
    () => {
      setFields({ ceType, fields: [] });
    },
  );

  return fields;
}

export default useDataTransferFields;
