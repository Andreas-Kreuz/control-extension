import { ReactElement, useCallback, useEffect, useState } from 'react';
import AppBar from '@mui/material/AppBar';
import BottomNavigation from '@mui/material/BottomNavigation';
import BottomNavigationAction from '@mui/material/BottomNavigationAction';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Paper from '@mui/material/Paper';
import Toolbar from '@mui/material/Toolbar';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import { Link as RouterLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import type { ReactNode } from 'react';
import { SideSheetContext, defaultSideSheetState } from '../contexts/SideSheetContext';
import type { SideSheetState } from '../contexts/SideSheetContext';
import AppBackButton from './AppBackButton';

const DRAWER_WIDTH = 240;
const RAIL_WIDTH = 80;
const SIDE_SHEET_WIDTH = 320;

export interface NavItem {
  icon: ReactElement;
  label: string;
  path: string;
}

interface AppLayoutProps {
  navItems: NavItem[];
}

function AppLayout({ navItems }: AppLayoutProps) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'lg'));
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));

  const [sideSheetState, setSideSheetState] = useState<SideSheetState>(defaultSideSheetState);

  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    setSideSheetState(defaultSideSheetState);
  }, [location.pathname]);

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
    const idx = navItems.findIndex(
      (item) => location.pathname === item.path || location.pathname.startsWith(item.path + '/'),
    );
    return idx >= 0 ? idx : 0;
  })();

  const handleNavigation = (path: string) => {
    navigate(path);
  };

  const sideSheetPermanent = isDesktop || (isTablet && sideSheetState.permanentOnTablet);
  const toolbarVariant = isDesktop ? 'regular' : 'dense';

  return (
    <SideSheetContext.Provider value={{ state: sideSheetState, setSheet, closeSheet }}>
      <Box sx={{ display: 'flex', minHeight: '100vh' }}>
        {/* App Bar */}
        <AppBar
          position="fixed"
          sx={{
            left: 0,
            width: '100%',
          }}
        >
          <Toolbar variant={toolbarVariant}>
            <AppBackButton sx={{ mr: 2, color: theme.palette.primary.contrastText }} />
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

        {/* Desktop: Permanent Navigation Drawer */}
        {isDesktop && (
          <Drawer
            variant="permanent"
            sx={{
              width: DRAWER_WIDTH,
              flexShrink: 0,
              '& .MuiDrawer-paper': {
                width: DRAWER_WIDTH,
                boxSizing: 'border-box',
                top: 64,
                height: 'calc(100% - 64px)',
              },
            }}
          >
            <List>
              {navItems.map((item, index) => (
                <ListItemButton
                  key={item.path}
                  selected={activeIndex === index}
                  onClick={() => handleNavigation(item.path)}
                >
                  <ListItemIcon>{item.icon}</ListItemIcon>
                  <ListItemText primary={item.label} />
                </ListItemButton>
              ))}
            </List>
          </Drawer>
        )}

        {/* Tablet: Navigation Rail */}
        {isTablet && (
          <Drawer
            variant="permanent"
            sx={{
              width: RAIL_WIDTH,
              flexShrink: 0,
              '& .MuiDrawer-paper': {
                width: RAIL_WIDTH,
                boxSizing: 'border-box',
                overflowX: 'hidden',
                top: 48,
                height: 'calc(100% - 48px)',
              },
            }}
          >
            <List disablePadding>
              {navItems.map((item, index) => (
                <Tooltip key={item.path} title={item.label} placement="right">
                  <ListItemButton
                    selected={activeIndex === index}
                    onClick={() => handleNavigation(item.path)}
                    sx={{ flexDirection: 'column', py: 1, px: 0, minHeight: 64 }}
                  >
                    <ListItemIcon sx={{ justifyContent: 'center', minWidth: 'auto' }}>{item.icon}</ListItemIcon>
                    <Typography variant="caption" align="center" noWrap sx={{ fontSize: '0.6rem', width: '100%' }}>
                      {item.label}
                    </Typography>
                  </ListItemButton>
                </Tooltip>
              ))}
            </List>
          </Drawer>
        )}

        {/* Main content */}
        <Box
          component="main"
          sx={{
            flexGrow: 1,
            minWidth: 0,
            pb: isMobile ? '56px' : 0,
          }}
        >
          <Toolbar variant={toolbarVariant} />
          <Outlet />
        </Box>

        {/* Side Sheet: permanent (desktop, optionally tablet) */}
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

        {/* Side Sheet: modal (tablet without permanent, mobile) */}
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

        {/* Mobile: Bottom Navigation */}
        {isMobile && (
          <Paper
            sx={{ position: 'fixed', bottom: 0, left: 0, right: 0, border: 0, zIndex: theme.zIndex.appBar }}
            elevation={3}
          >
            <BottomNavigation
              value={activeIndex}
              onChange={(_, newValue: number) => handleNavigation(navItems[newValue]?.path ?? '/')}
              sx={{
                bgcolor: 'primary.main',
                '& .MuiBottomNavigationAction-root': { color: 'primary.contrastText', opacity: 0.7 },
                '& .MuiBottomNavigationAction-root.Mui-selected': { color: 'primary.contrastText', opacity: 1 },
              }}
            >
              {navItems.map((item) => (
                <BottomNavigationAction key={item.path} label={item.label} icon={item.icon} />
              ))}
            </BottomNavigation>
          </Paper>
        )}
      </Box>
    </SideSheetContext.Provider>
  );
}

export default AppLayout;
