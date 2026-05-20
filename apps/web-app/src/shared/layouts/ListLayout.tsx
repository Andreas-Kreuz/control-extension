import { Fragment, useCallback, useEffect, useState } from 'react';
import type { ReactElement, ReactNode } from 'react';
import Box from '@mui/material/Box';
import Collapse from '@mui/material/Collapse';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import CloseIcon from '@mui/icons-material/Close';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import { useSideSheet } from '../../app/contexts/SideSheetContext';
import { Paper } from '@mui/material';
import { DetailTabPanelBody, IconHeaderSection } from '../components/sections';

export interface DetailSection {
  title: string;
  component: ReactNode;
  icon?: ReactElement;
  sidePanelOnly?: boolean;
}

export interface ListLayoutProps<T> {
  items: T[];
  keyExtractor: (item: T) => string;
  renderCard: (item: T, selected: boolean, onSelect: () => void, mobileExpansion?: ReactNode) => ReactNode;
  renderListItem: (item: T, selected: boolean, onSelect: () => void) => ReactNode;
  getDetails: (item: T) => DetailSection[];
  getFilterText: (item: T) => string;
  filterLabel?: string;
  emptyMessage?: ReactNode | ((filterText: string) => ReactNode);
  placeholder?: ReactNode;
  filterSlot?: ReactNode;
  permanentDetailsOnTablet?: boolean;
  selectedElement: string | undefined;
  onSelectedElementChange: (selectedElement: string | null) => void;
}

function MobileTabs({ sections }: { sections: DetailSection[] }) {
  const [activeTab, setActiveTab] = useState(0);
  const visibleSections = sections.filter((section) => !section.sidePanelOnly);
  const safeTab = Math.min(activeTab, visibleSections.length - 1);

  if (visibleSections.length === 0) {
    return null;
  }

  if (visibleSections.length === 1) {
    return <DetailTabPanelBody>{visibleSections[0]?.component}</DetailTabPanelBody>;
  }

  return (
    <Stack>
      <Tabs
        value={safeTab}
        onChange={(_, v: number) => setActiveTab(v)}
        variant="scrollable"
        allowScrollButtonsMobile
        sx={{ minHeight: 44 }}
      >
        {visibleSections.map((s) => (
          <Tab key={s.title} label={s.title} />
        ))}
      </Tabs>
      <Divider />
      <DetailTabPanelBody>{visibleSections[safeTab]?.component}</DetailTabPanelBody>
    </Stack>
  );
}

function SideSheetDetail({ sections, onClose }: { sections: DetailSection[]; onClose: () => void }) {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', flexGrow: 1, minHeight: 0 }}>
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 0.5 }}>
        <IconButton onClick={onClose} size="small" aria-label="Schließen">
          <CloseIcon />
        </IconButton>
      </Box>
      <Divider />
      <Box sx={{ overflowY: 'auto', flexGrow: 1 }}>
        {sections.map((section) => (
          <IconHeaderSection key={section.title} title={section.title} icon={section.icon}>
            {section.component}
          </IconHeaderSection>
        ))}
      </Box>
    </Box>
  );
}

function SideSheetPlaceholder() {
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', p: 4 }}>
      <Typography variant="body2" color="textSecondary" align="center">
        Wähle einen Eintrag
      </Typography>
    </Box>
  );
}

function ListLayout<T>({
  items,
  keyExtractor,
  renderCard,
  renderListItem,
  getDetails,
  getFilterText,
  filterLabel = 'Filter',
  emptyMessage,
  placeholder,
  filterSlot,
  permanentDetailsOnTablet = false,
  selectedElement,
  onSelectedElementChange,
}: ListLayoutProps<T>) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));

  const [filterText, setFilterText] = useState('');
  const normalizedFilter = filterText.trim().toLocaleLowerCase();
  const filteredItems = normalizedFilter
    ? items.filter((item) => getFilterText(item).toLocaleLowerCase().includes(normalizedFilter))
    : items;
  const selectedKey = selectedElement ?? null;
  const selectedItem = selectedKey !== null ? (items.find((item) => keyExtractor(item) === selectedKey) ?? null) : null;
  const { setSheet, closeSheet } = useSideSheet();

  const updateSelectedKey = useCallback(
    (nextSelectedKey: string | null) => {
      onSelectedElementChange(nextSelectedKey);
    },
    [onSelectedElementChange],
  );

  const handleClose = useCallback(() => {
    updateSelectedKey(null);
  }, [updateSelectedKey]);

  const handleSelect = useCallback(
    (key: string) => {
      updateSelectedKey(selectedKey === key ? null : key);
    },
    [selectedKey, updateSelectedKey],
  );

  useEffect(() => {
    if (isMobile) {
      closeSheet();
      return;
    }

    if (selectedItem && selectedKey) {
      const sections = getDetails(selectedItem);
      setSheet(<SideSheetDetail sections={sections} onClose={handleClose} />, {
        permanentOnTablet: permanentDetailsOnTablet,
        key: selectedKey,
      });
      return;
    }

    if (isDesktop) {
      setSheet(placeholder ?? <SideSheetPlaceholder />, { permanentOnTablet: permanentDetailsOnTablet });
    } else {
      closeSheet();
    }
  }, [
    selectedItem,
    selectedKey,
    getDetails,
    isDesktop,
    isMobile,
    placeholder,
    permanentDetailsOnTablet,
    handleClose,
    setSheet,
    closeSheet,
  ]);

  // Cleanup on unmount
  useEffect(() => {
    return () => closeSheet();
  }, [closeSheet]);

  const resolvedEmptyMessage =
    filteredItems.length === 0 && emptyMessage !== undefined
      ? typeof emptyMessage === 'function'
        ? emptyMessage(filterText)
        : emptyMessage
      : null;

  return (
    <Stack spacing={2}>
      <TextField
        size="small"
        label={filterLabel}
        value={filterText}
        onChange={(e) => setFilterText(e.target.value)}
        fullWidth
      />
      {filterSlot}
      {resolvedEmptyMessage}
      {isMobile
        ? filteredItems.map((item) => {
            const key = keyExtractor(item);
            const selected = key === selectedKey;
            const mobileExpansion = (
              <Collapse in={selected} mountOnEnter unmountOnExit>
                <Divider sx={{ width: 1 }} />
                <MobileTabs sections={getDetails(item)} />
              </Collapse>
            );
            return <Box key={key}>{renderCard(item, selected, () => handleSelect(key), mobileExpansion)}</Box>;
          })
        : filteredItems.length > 0 && (
            <Paper>
              <List>
                {filteredItems.map((item, index) => {
                  const key = keyExtractor(item);
                  const selected = key === selectedKey;
                  return (
                    <>
                      {index !== 0 && <Divider />}
                      <Fragment key={key}>{renderListItem(item, selected, () => handleSelect(key))}</Fragment>
                    </>
                  );
                })}
              </List>
            </Paper>
          )}
    </Stack>
  );
}

export default ListLayout;
