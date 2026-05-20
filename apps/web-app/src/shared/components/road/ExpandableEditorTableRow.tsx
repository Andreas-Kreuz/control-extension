import Collapse from '@mui/material/Collapse';
import IconButton from '@mui/material/IconButton';
import TableCell from '@mui/material/TableCell';
import TableRow from '@mui/material/TableRow';
import { alpha } from '@mui/material/styles';
import DeleteIcon from '@mui/icons-material/Delete';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardArrowRightIcon from '@mui/icons-material/KeyboardArrowRight';
import type { ReactNode } from 'react';

function ExpandableEditorTableRow(props: {
  ariaLabel: string;
  children: ReactNode;
  dataCellCount: number;
  deletable?: boolean;
  editor: ReactNode;
  expanded: boolean;
  onDelete?: () => void;
  onToggle: () => void;
}) {
  return (
    <>
      <TableRow
        hover
        selected={props.expanded}
        onClick={props.onToggle}
        sx={(theme) => ({
          cursor: 'pointer',
          bgcolor: props.expanded ? alpha(theme.palette.primary.main, 0.08) : undefined,
          boxShadow: props.expanded ? `inset 3px 0 0 ${theme.palette.primary.main}` : undefined,
          transition: 'background-color 120ms ease',
          '&:hover': {
            bgcolor: props.expanded ? alpha(theme.palette.primary.main, 0.12) : undefined,
          },
          '& > .MuiTableCell-root': {
            borderBottomWidth: props.expanded ? 0 : 1,
          },
        })}
      >
        <TableCell>
          <IconButton
            size="small"
            aria-label={`${props.ariaLabel} ${props.expanded ? 'einklappen' : 'ausklappen'}`}
            title={props.expanded ? 'Editor einklappen' : 'Editor ausklappen'}
            sx={{ px: 0.5 }}
            onClick={(event) => {
              event.stopPropagation();
              props.onToggle();
            }}
          >
            {props.expanded ? <KeyboardArrowDownIcon /> : <KeyboardArrowRightIcon />}
          </IconButton>
        </TableCell>
        {props.children}
        <TableCell align="right" onClick={(event) => event.stopPropagation()}>
          {props.deletable && (
            <IconButton
              size="small"
              color="error"
              aria-label={`${props.ariaLabel} löschen`}
              title={`${props.ariaLabel} löschen`}
              onClick={props.onDelete}
            >
              <DeleteIcon fontSize="small" />
            </IconButton>
          )}
        </TableCell>
      </TableRow>
      <TableRow
        sx={{
          '& > .MuiTableCell-root': {
            borderBottomWidth: props.expanded ? 1 : 0,
          },
        }}
      >
        <TableCell
          sx={(theme) => ({
            py: 0,
            bgcolor: alpha(theme.palette.primary.main, 0.025),
          })}
        />
        <TableCell colSpan={props.dataCellCount + 1} sx={{ py: 0 }}>
          <Collapse in={props.expanded} timeout="auto" unmountOnExit>
            {props.editor}
          </Collapse>
        </TableCell>
      </TableRow>
    </>
  );
}

export default ExpandableEditorTableRow;
