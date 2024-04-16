import * as React from "react";
import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Typography from "@mui/material/Typography";
import Grid from "@mui/material/Grid";

const bull = (
  <Box
    component="span"
    sx={{ display: "inline-block", mx: "2px", transform: "scale(0.8)" }}
  >
    •
  </Box>
);

export default function Services() {
  return (
    <div style={{ height: "400px", overflow: "auto" }}>
      <Grid container spacing={5} justify="center">
        <Grid item xs={6}>
          <Card sx={{ width: "100%", background: "#3CB371" }}>
            <CardContent>
              <Typography
                sx={{ fontSize: 14 }}
                color="text.secondary"
                gutterBottom
                fontFamily="monospace"
              >
                <strong>Cost Effective</strong>
              </Typography>
              <Typography fontFamily="monospace">
                Faster generated code means less cycles which means reduced
                cost.
              </Typography>
            </CardContent>
          </Card>

          <div style={{ marginTop: "20px" }}>
            <Card sx={{ width: "100%", background: "#3CB371" }}>
              <CardContent>
                <Typography fontFamily="monospace">Faster</Typography>
                <Typography
                  sx={{ fontSize: 14 }}
                  color="text.secondary"
                  gutterBottom
                  fontFamily="monospace"
                >
                  Generate efficient matrix multiplication kernels
                </Typography>
              </CardContent>
            </Card>
          </div>
          <div style={{ marginTop: "20px" }}>
            <Card sx={{ width: "100%", background: "#3CB371" }}>
              <CardContent>
                <Typography fontFamily="monospace">Educational</Typography>
                <Typography
                  sx={{ fontSize: 14 }}
                  color="text.secondary"
                  gutterBottom
                  fontFamily="monospace"
                >
                  Learn how constructs get represented in assembly
                </Typography>
              </CardContent>
            </Card>
          </div>
        </Grid>
      </Grid>
    </div>
  );
}
