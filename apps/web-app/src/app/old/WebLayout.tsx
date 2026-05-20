import { useCallback, useState } from 'react';
import type { ReactNode } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { Link as RouterLink, Outlet } from 'react-router-dom';
import BackButton from '../components/BackButton';
import { SideSheetContext, defaultSideSheetState } from '../contexts/SideSheetContext';
import type { SideSheetState } from '../contexts/SideSheetContext';

const SIDE_SHEET_WIDTH = 360;

function WebLayout() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'lg'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));
  const [sideSheetState, setSideSheetState] = useState<SideSheetState>(defaultSideSheetState);

  const setSheet = useCallback((content: ReactNode, options?: { permanentOnTablet?: boolean; key?: string }) => {
    setSideSheetState({
      content,
      open: true,
      permanentOnTablet: options?.permanentOnTablet ?? false,
      selectedKey: options?.key ?? null,
    });
  }, []);

  const closeSheet = useCallback(() => {
    setSideSheetState(defaultSideSheetState);
  }, []);

  const sideSheetPermanent = isDesktop || (isTablet && sideSheetState.permanentOnTablet);

  return (
    <SideSheetContext.Provider value={{ state: sideSheetState, setSheet, closeSheet }}>
      <div className="Client">
        <Box sx={{ display: 'flex', minHeight: '100vh' }}>
          <AppBar>
            <Toolbar>
              <BackButton sx={{ mr: 2, color: theme.palette.primary.contrastText }} />
              <Typography
                variant="h6"
                component={RouterLink}
                to={'/'}
                sx={{
                  flexGrow: 1,
                  display: 'block',
                  textDecoration: 'none',
                  color: theme.palette.primary.contrastText,
                }}
              >
                Control Extension App
              </Typography>
            </Toolbar>
          </AppBar>
          <Box component="main" sx={{ flexGrow: 1, minWidth: 0 }}>
            <Toolbar />
            <Outlet />
          </Box>
          {sideSheetState.content && sideSheetPermanent && (
            <Drawer
              variant="permanent"
              anchor="right"
              sx={{
                width: SIDE_SHEET_WIDTH,
                flexShrink: 0,
                '& .MuiDrawer-paper': {
                  width: SIDE_SHEET_WIDTH,
                  boxSizing: 'border-box',
                  overflow: 'hidden',
                  display: 'flex',
                  flexDirection: 'column',
                  top: 64,
                  height: 'calc(100% - 64px)',
                },
              }}
            >
              {sideSheetState.content}
            </Drawer>
          )}
          {sideSheetState.content && !sideSheetPermanent && (
            <Drawer
              variant="temporary"
              anchor="right"
              open={sideSheetState.open}
              onClose={closeSheet}
              sx={{
                '& .MuiDrawer-paper': {
                  width: isMobile ? '100%' : SIDE_SHEET_WIDTH,
                },
              }}
            >
              {isMobile && <Toolbar variant="dense" />}
              {sideSheetState.content}
            </Drawer>
          )}
        </Box>
      </div>
    </SideSheetContext.Provider>
  );
}

export default WebLayout;
