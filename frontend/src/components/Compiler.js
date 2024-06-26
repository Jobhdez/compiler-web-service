import React, { useState } from "react";
import {
  Box,
  Button,
  Typography,
  FormControl,
  Grid,
  InputLabel,
  MenuItem,
  Select,
  TextField,
} from "@mui/material";
import Editor from "@monaco-editor/react";

function Compiler() {
  const [ExpCode, setExpCode] = useState("");
  const [CompiledCode, setCompiledCode] = useState("");
  const [comp, setComp] = useState(null);
  const [url, setUrl] = useState("");
  const [user, setUser] = useState("");

  const handleChange = (event) => {
    setComp(event.target.value);
  };

  const CpsHandle = () => {
    setUrl("cps-compilations");
  };

  const ScmHandle = () => {
    setUrl("scm-compilations");
  };

  const PyHandle = () => {
    setUrl("py-compilations");
  };

  const LalgHandle = () => {
    setUrl("lalg-compilations");
  };
  const lispApi = "http://localhost:4243/";

  function Compile() {
    var data = new URLSearchParams();
    //data.append("user", user);
    data.append("exp", ExpCode);
    console.log(typeof user);
    console.log(typeof ExpCode);
    fetch(lispApi + url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: data,
      mode: "cors",
    })
      .then((response) => response.json())
      .then((data) => {
        setCompiledCode(data.expression);
      });
  }

  return (
    <div>
      <Grid container spacing={2}>
        <Grid item>
          <FormControl size="small">
            <InputLabel
              sx={{
                color: "black",
                fontFamily: "monospace",
              }}
            >
              Compilers
            </InputLabel>
            <Select
              label="Compilers"
              value={comp}
              onChange={handleChange}
              sx={{
                width: 250,
                height: 50,
                backgroundColor: "#3CB371",
              }}
            >
              <MenuItem value={1} onClick={CpsHandle}>
                CPS Compiler
              </MenuItem>
              <MenuItem value={2} onClick={ScmHandle}>
                Scheme to Lambda compiler
              </MenuItem>
              <MenuItem value={3} onClick={PyHandle}>
                Py compiler
              </MenuItem>
              <MenuItem value={4} onClick={LalgHandle}>
                Lalg Compiler
              </MenuItem>
            </Select>
          </FormControl>
        </Grid>
      </Grid>
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <Box>
            <Editor
              height="calc(50vh - 25px)"
              theme="vs-light"
              onChange={(val) => {
                setExpCode(val);
              }}
            />
          </Box>
        </Grid>
        <Grid item xs={4}>
          <Box>
            <pre>
              <code>{CompiledCode}</code>
            </pre>
          </Box>
        </Grid>
      </Grid>

      <Button
        onClick={Compile}
        variant="contained"
        sx={{
          backgroundColor: "#3CB371",
          color: "black",
          "&:hover": {
            backgroundColor: "darkgray", // Set a different color on hover if desired
          },
        }}
      >
        Compile Exp
      </Button>
    </div>
  );
}
export default Compiler;
