import React from "react";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";
import Services from "./Services";
import Button from "@mui/material/Button";
import Compiler from "./Compiler";
import SlidingBanner from "./SlidingBanner"
import BeachAccessIcon from "@mui/icons-material/BeachAccess";
import CoffeeIcon from "@mui/icons-material/Coffee";
import BrightnessHighIcon from "@mui/icons-material/BrightnessHigh";

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
          <Typography variant="h2" align="center" fontFamily="monospace">
            Effient
          </Typography>
          <Typography variant="h2" align="center" fontFamily="monospace">
            compilation engine
          </Typography>
          <Typography
            style={{ marginTop: "10px" }}
            fontFamily="monospace"
            align="center"
          >
            {" "}
            Build your own interview engine using efficient cloud compilers
          </Typography>
        </Grid>
        <Grid item xs={6}>
          <Typography variant="h6" fontFamily="monospace">
            <BeachAccessIcon
              style={{ verticalAlign: "middle", marginRight: "5px" }}
            />
            Scheme API
          </Typography>
          <Typography style={{ marginTop: "10px" }} fontFamily="monospace">
            Efficient Scheme to CPS computation for education
          </Typography>
          <Typography></Typography>
          <Typography
            variant="h6"
            style={{ marginTop: "10px" }}
            fontFamily="monospace"
          >
            <CoffeeIcon
              style={{ verticalAlign: "middle", marginRight: "5px" }}
            />
            Matrix API
          </Typography>
          <Typography style={{ marginTop: "10px" }} fontFamily="monospace">
            Generate efficient matrix and vector kernels
          </Typography>
          <Typography></Typography>
          <Typography
            variant="h6"
            fontFamily="monospace"
            style={{ marginTop: "10px" }}
          >
            <BrightnessHighIcon
              style={{ verticalAlign: "middle", marginRight: "5px" }}
            />
            Python API
          </Typography>
          <Typography style={{ marginTop: "10px" }} fontFamily="monospace">
            Call a Python like language and compute in the cloud
          </Typography>
        </Grid>
      </Grid>
      <div style={{ marginTop: "350px", marginLeft: "20px" }}>
          <Services />
	  <SlidingBanner/>
        <Compiler />
      </div>
    </div>
  );
}

export default Home;
