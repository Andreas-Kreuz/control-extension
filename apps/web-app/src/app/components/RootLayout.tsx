import { useCallback, useState } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import { Link as RouterLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import type { ReactNode } from 'react';
import { NavDesktop, NavMobile, NavTablet, type NavItem } from '../../shared/components/nav';
import { SideSheetContext, defaultSideSheetState } from '../contexts/SideSheetContext';
import type { SideSheetState } from '../contexts/SideSheetContext';
import useModuleAvailability from '../hooks/useModuleAvailability';
import BackButton from './BackButton';

const SIDE_SHEET_WIDTH = 320;
const DESKTOP_SIDE_SHEET_WIDTH = 'calc((100vw - 240px) / 2)';

interface RootLayoutProps {
  navItems: NavItem[];
}

function RootLayout({ navItems }: RootLayoutProps) {
  const theme = useTheme();
  const { isModuleAvailable } = useModuleAvailability();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'lg'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));
  const visibleNavItems = navItems.filter(
    (item) => item.requiredModuleId === undefined || isModuleAvailable(item.requiredModuleId),
  );

  const [sideSheetState, setSideSheetState] = useState<SideSheetState>(defaultSideSheetState);

  const location = useLocation();
  const navigate = useNavigate();
  const hideNav = location.pathname.startsWith('/road/createIntersection');

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

  const activeIndex = (() => {
    const idx = visibleNavItems.findIndex(
      (item) => location.pathname === item.path || location.pathname.startsWith(item.path + '/'),
    );
    return idx >= 0 ? idx : 0;
  })();

  const handleNavigation = (path: string) => {
    navigate(path);
  };

  const sideSheetPermanent = isDesktop || (isTablet && sideSheetState.permanentOnTablet);
  const sideSheetWidth = isDesktop ? DESKTOP_SIDE_SHEET_WIDTH : SIDE_SHEET_WIDTH;
  const toolbarVariant = isDesktop ? 'regular' : 'dense';

  return (
    <SideSheetContext.Provider value={{ state: sideSheetState, setSheet, closeSheet }}>
      <Box sx={{ display: 'flex', minHeight: '100vh' }}>
        <AppBar
          position="fixed"
          sx={{
            left: 0,
            width: '100%',
          }}
        >
          <Toolbar variant={toolbarVariant}>
            <BackButton sx={{ mr: 2, color: theme.palette.primary.contrastText }} />
            <Typography
              variant="h6"
              component={RouterLink}
              to="/"
              sx={{ flexGrow: 1, textDecoration: 'none', color: theme.palette.primary.contrastText }}
            >
              Control Extension App
            </Typography>
          </Toolbar>
        </AppBar>

        {isDesktop && !hideNav && (
          <NavDesktop items={visibleNavItems} activeIndex={activeIndex} onNavigate={handleNavigation} />
        )}

        {isTablet && !hideNav && (
          <NavTablet items={visibleNavItems} activeIndex={activeIndex} onNavigate={handleNavigation} />
        )}

        <Box
          component="main"
          sx={{
            flexGrow: 1,
            minWidth: 0,
            pb: isMobile && !hideNav ? '56px' : 0,
          }}
        >
          <Toolbar variant={toolbarVariant} />
          <Outlet />
        </Box>

        {sideSheetState.content && sideSheetPermanent && (
          <Drawer
            variant="permanent"
            anchor="right"
            sx={{
              width: sideSheetWidth,
              flexShrink: 0,
              '& .MuiDrawer-paper': {
                width: sideSheetWidth,
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

        {isMobile && !hideNav && (
          <NavMobile items={visibleNavItems} activeIndex={activeIndex} onNavigate={handleNavigation} />
        )}
      </Box>
    </SideSheetContext.Provider>
  );
}

export type { NavItem };
export default RootLayout;
