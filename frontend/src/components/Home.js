import React from "react";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";
import Services from "./Services";
import Button from "@mui/material/Button";

function Home() {
  return (
    <div
      style={{
        minHeight: "100vh", // Ensure the content stretches to at least the full viewport height
        background: "linear-gradient(to bottom, #3CB371, #FFFFFF)",
        paddingTop: "100px",
        paddingBottom: "100px",
        position: "relative", // Add relative positioning to the container
      }}
    >
      <Grid container spacing={2} alignItems="center" justifyContent="center">
        <Grid item xs={6}>
          <Typography variant="h3" align="center" fontFamily="monospace">
            Effient
          </Typography>
          <Typography variant="h3" align="center" fontFamily="monospace">
            compilation engine
          </Typography>
        </Grid>
        <Grid item xs={6}>
          <Typography variant="h6" fontFamily="monospace">
            Scheme to CPS compilation
          </Typography>
          <Typography></Typography>
          <Typography variant="h6" fontFamily="monospace">
            Generate efficient linear algebra kernels
          </Typography>
          <Typography></Typography>
          <Typography variant="h6" fontFamily="monospace">
            API for a Python like compiler
          </Typography>
        </Grid>
      </Grid>
      <div style={{ marginTop: "350px", marginLeft: "20px" }}>
        <Services />
      </div>
    </div>
  );
}

export default Home;
