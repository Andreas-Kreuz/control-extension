import { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';

function useSelectedElementNavigation(selectedElement?: string) {
  const navigate = useNavigate();

  return useCallback(
    (nextSelectedElement: string | null) => {
      if (nextSelectedElement === null) {
        if (selectedElement !== undefined) {
          navigate('..', { relative: 'path' });
        }
        return;
      }

      const nextPath = encodeURIComponent(nextSelectedElement);
      if (selectedElement === undefined) {
        navigate(nextPath, { relative: 'path' });
        return;
      }

      navigate(`../${nextPath}`, { relative: 'path' });
    },
    [navigate, selectedElement],
  );
}

export default useSelectedElementNavigation;
