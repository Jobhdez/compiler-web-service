import React from "react";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";

function Home() {
  return (
    <div
      style={{
        background: "linear-gradient(to bottom, #B0E0E6, #FFFFFF)",
        paddingTop: "100px",
        paddingBottom: "100px",
      }}
    >
      <Grid container spacing={2} alignItems="center" justifyContent="center">
        <Grid item xs={6}>
          <Typography variant="h1" align="center">
            {" "}
            {/* Centered typography */}
            Efficient
          </Typography>
          <Typography variant="h2" align="center">
            {" "}
            {/* Centered typography */}
            Computation for the cloud
          </Typography>
        </Grid>
        <Grid item xs={6}>
          <Typography variant="h3">
            {" "}
            {/* Typography without alignment */}
            An efficient Scheme desugarer
          </Typography>
          <Typography variant="h3">
            {" "}
            {/* Typography without alignment */}A powerful linear algebra
            compiler
          </Typography>
          <Typography variant="h3">
            {" "}
            {/* Typography without alignment */}A fast CPS converter and Python
            like language
          </Typography>
        </Grid>
      </Grid>
    </div>
  );
}

export default Home;
