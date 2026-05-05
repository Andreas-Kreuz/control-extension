import type { ReactElement } from 'react';

export interface NavItem {
  icon: ReactElement;
  label: string;
  path: string;
  requiredModuleId?: string;
}
