import * as React from 'react';
import { styled } from '@mui/material/styles';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import MenuIcon from '@mui/icons-material/Menu';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import McCarthy from '../assets/lisp.png';

const StyledToolbar = styled(Toolbar)(({ theme }) => ({
  alignItems: 'flex-start',
  paddingTop: theme.spacing(1),
  paddingBottom: theme.spacing(2),
  // Override media queries injected by theme.mixins.toolbar
  '@media all': {
    minHeight: 128,
  },
}));

const StyledImg = styled('img')(({ theme }) => ({
    marginRight: theme.spacing(30),
    maxHeight: 150,
}));
function Header() {
  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);
  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };
  const handleClose = () => {
    setAnchorEl(null);
  };
  return (
    <Box sx={{ flexGrow: 1 }}>
	<AppBar position="static"
		style={{background: '#000000' }}
	>
	<StyledToolbar>
          <IconButton
            size="large"
            edge="start"
            color="inherit"
            aria-label="open drawer"
            sx={{ mr: 2 }}
	      onClick={handleClick}  
          >
            <MenuIcon />
          </IconButton>
	    <Menu id="basic-menu" anchorEl={anchorEl}
		  open={open}
		  onClose={handleClose}
		  MenuListProps={{'aria-labelledby': 'basic-button',}}>
		<MenuItem>Listing</MenuItem>
		<MenuItem>Detailed</MenuItem>
	</Menu>
          <Typography
            variant="h5"
            noWrap
            component="div"
            sx={{ flexGrow: 1, alignSelf: 'flex-end' }}
          >
	      Explore my compilers :-)
          </Typography>
	    <StyledImg src={McCarthy} />
        </StyledToolbar>
      </AppBar>
    </Box>
  );
}

export default Header;
