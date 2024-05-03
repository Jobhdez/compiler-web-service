import React, { useState, useEffect } from "react";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";
import { motion, useAnimation } from "framer-motion"; // Import motion components
import Services from "./Services";
import Button from "@mui/material/Button";
import Compiler from "./Compiler";
import SlidingBanner from "./SlidingBanner";
import BeachAccessIcon from "@mui/icons-material/BeachAccess";
import CoffeeIcon from "@mui/icons-material/Coffee";
import BrightnessHighIcon from "@mui/icons-material/BrightnessHigh";

function Home() {
  const [text, setText] = useState("Efficient");

  useEffect(() => {
    const interval = setInterval(() => {
      setText((prevText) => {
        if (prevText === "Efficient") return "Customizable";
        else if (prevText === "Customizable") return "Reliable";
        else return "Efficient";
      });
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "linear-gradient(to bottom, #3CB371, #FFFFFF)",
        paddingTop: "100px",
        paddingBottom: "100px",
        position: "relative",
      }}
    >
      <Grid container spacing={2} alignItems="center" justifyContent="center">
        <Grid item xs={6}>
          <motion.div
            initial={{ opacity: 0 }} // Initial opacity
            animate={{ opacity: 1 }} // Animate to fully visible
            transition={{ duration: 1 }} // Animation duration
          >
            <Typography
              variant="h2"
              align="center"
              color="white"
              fontFamily="monospace"
            >
              {text}
            </Typography>
            <Typography
              variant="h2"
              align="center"
              fontFamily="monospace"
              style={{ marginTop: "-20px" }} // Adjust spacing
            >
              compilation engine
            </Typography>
          </motion.div>
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
        <Compiler />
      </div>
    </div>
  );
}

export default Home;
