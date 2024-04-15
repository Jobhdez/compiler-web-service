function Compiler() {
  const [ExpCode, setExpCode] = useState("");
  const [CompiledCode, setCompiledCode] = useState("");
  const [comp, setComp] = React.useState(null);
  const [url, setUrl] = React.useState("");
  const [user, setUser] = React.useState("");

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

  const scm = "Scheme to Lambda compiler";

  function Compile() {
    var data = new URLSearchParams();
    data.append("user", user);
    data.append("exp", ExpCode);
    console.log(typeof user);
    console.log(typeof ExpCode);
    fetch(lispUrl + url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: data,
      mode: "cors",
    }).then((response) => {
      if (!response.ok) {
        throw new Error("network response was not ok");
      }
      return response.json();
    });
  }

  const [ExpCode, setExpCode] = useState("");
  const [CompiledCode, setCompiledCode] = useState("");
  const [comp, setComp] = React.useState(null);
  const [url, setUrl] = React.useState("");
  const [user, setUser] = React.useState("");

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

  return (
    <div>
      <Grid container spacing={2}>
        <Grid item>
          <FormControl size="small">
            <InputLabel
              sx={{
                color: "white", // Set label color to white
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
                backgroundColor: "black",
                color: "white",
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
                {" "}
                Lalg Compiler
              </MenuItem>
            </Select>
          </FormControl>
        </Grid>
        <Grid item>
          <Box
            component="form"
            sx={{
              "& > :not(style)": { m: 1, width: "25ch" },
            }}
            noValidate
            autoComplete="off"
          >
            <TextField
              id="outlined-controlled"
              label="Username"
              value={user}
              onChange={(event) => {
                setUser(event.target.value);
              }}
              InputLabelProps={{
                style: { color: "white" }, // Set label color to white
              }}
              sx={{
                backgroundColor: "black",
                "& input": {
                  color: "white",
                },
              }}
            />
          </Box>
        </Grid>
      </Grid>
      <Grid container spacing={2}>
        <Grid item xs={8}>
          <item>
            <Editor
              height="calc(50vh - 25px)"
              theme="vs-dark"
              onChange={(val) => {
                setExpCode(val);
              }}
            />
          </item>
        </Grid>
        <Grid item xs={4}>
          <item>
            <pre>
              {" "}
              <code>{CompiledCode} </code>
            </pre>
          </item>
        </Grid>
      </Grid>

      <Button
        onClick={Compile}
        variant="contained"
        sx={{
          backgroundColor: "black", // Set black background
          color: "white", // Set text color to white
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
