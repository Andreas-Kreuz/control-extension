import { createContext, useContext } from 'react';
import type { ReactNode } from 'react';

export interface SideSheetState {
  content: ReactNode | null;
  open: boolean;
  permanentOnTablet: boolean;
  selectedKey: string | null;
}

export const defaultSideSheetState: SideSheetState = {
  content: null,
  open: false,
  permanentOnTablet: false,
  selectedKey: null,
};

export interface SideSheetContextValue {
  state: SideSheetState;
  setSheet: (content: ReactNode, options?: { permanentOnTablet?: boolean; key?: string }) => void;
  closeSheet: () => void;
}

export const SideSheetContext = createContext<SideSheetContextValue>({
  state: defaultSideSheetState,
  setSheet: () => {},
  closeSheet: () => {},
});

export const useSideSheet = () => useContext(SideSheetContext);
