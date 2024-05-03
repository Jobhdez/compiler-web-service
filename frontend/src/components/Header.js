import * as React from "react";
import { styled } from "@mui/material/styles";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import { NavLink as MuiLink } from "react-router-dom";

const StyledToolbar = styled(Toolbar)(({ theme }) => ({
  display: "flex",
  justifyContent: "space-between",
}));

function Header() {
  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="static" style={{ background: "#3CB371" }}>
        <Toolbar>
          <MuiLink
            to="/"
            color="inherit"
            fontFamily="monospace"
            align="center"
            style={{ textDecoration: "none", marginRight: "20px" }}
          >
            <Typography variant="h6" color="white">
              Manifold ML
            </Typography>
          </MuiLink>

          <MuiLink
            to="/cserve"
            color="white"
            fontFamily="monospace"
            align="center"
            style={{ textDecoration: "none", marginRight: "20px" }}
          >
            <Typography variant="h6" color="white" align="center">
              CServe
            </Typography>
          </MuiLink>

          <MuiLink
            to="/open-source-products"
            color="white"
            fontFamily="monospace"
            align="center"
            style={{ textDecoration: "none", marginRight: "20px" }}
          >
            <Typography variant="h6" color="white">
              Open Source Products
            </Typography>
          </MuiLink>

          <MuiLink
            to="/about"
            color="inherit"
            fontFamily="monospace"
            align="center"
            style={{ textDecoration: "none" }}
          >
            <Typography variant="h6" color="white">
              About
            </Typography>
          </MuiLink>
        </Toolbar>
      </AppBar>
    </Box>
  );
}

export default Header;
