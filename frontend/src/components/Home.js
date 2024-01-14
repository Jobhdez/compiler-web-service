import React from 'react';
import { useState } from 'react';
import Editor from "@monaco-editor/react";
import Button from '@mui/material/Button';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';

const lispUrl = "http://localhost:4243/"

function Home() {
    const [ExpCode, setExpCode] = useState("");
    const [CompiledCode, setCompiledCode] = useState("")
    const [anchorEl, setAnchorEl] = React.useState(null);
    const [url, setUrl] = React.useState("")
    const [user, setUser] = React.useState("")
    const handleClose = () => {
        setAnchorEl(null);
    };
    const open = Boolean(anchorEl);

    const handleClick = (event) => {
	setAnchorEl(event.currentTarget);
    };

    const CpsHandle = () => {
        setUrl("cps-compilations")
        setAnchorEl(null)
    }

    const ScmHandle = () => {
        setUrl("scm-compilations")
        setAnchorEl(null)
    }

    const PyHandle = () => {
        setUrl("py-compilations")
        setAnchorEl(null)
    }

    const LalgHandle = () => {
        setUrl("lalg-compilations")
        setAnchorEl(null)
    }


    function Compile() {
        var data = new URLSearchParams();
        data.append("user", user);
        data.append("exp", ExpCode);
        console.log(typeof user)
        console.log(typeof ExpCode)
        fetch(lispUrl+url, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: data,
            mode: 'cors'
        })
            .then(response => {
		if (!response.ok) {
                    throw new Error("network response was not ok")
		}
		return response.json()
            })
            .then(data => {
	
		setCompiledCode(JSON.stringify(data.expression))
            })
            .catch(error => {
		console.error('Error:', error);
            });
    }
    

    return (
	
	<div>
            <Grid container spacing={2}>
		<Grid item>
		    <Button
			id="basic-button"
			aria-controls={open ? 'basic-menu' : undefined}
			aria-haspopup="true"
			aria-expanded={open ? 'true' : undefined}
			onClick={handleClick}
		    >
			Pick your compiler
		    </Button>
		    <Menu
			id="basic-menu"
			anchorEl={anchorEl}
			open={open}
			onClose={handleClose}
			MenuListProps={{
			    'aria-labelledby': 'basic-button',
			}}
		    >
			<MenuItem onClick={CpsHandle}>CPS Compiler</MenuItem>
			<MenuItem onClick={ScmHandle}>Scheme to Lambda compiler</MenuItem>
			<MenuItem onClick={PyHandle}>Py compiler</MenuItem>
			<MenuItem onClick={LalgHandle}> Lalg Compiler</MenuItem>
		    </Menu>
		</Grid>
		<Grid item>
		    <Box
			component="form"
			sx={{
			    '& > :not(style)': { m: 1, width: '25ch' },
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
			/>
		    </Box>
		</Grid>
	    </Grid>
	    
	    <Editor height="calc(50vh - 25px)" theme="vs-dark" onChange={(val) => {setExpCode(val)}}/>
	    <button onClick={Compile}>compile</button>
	    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh', width: '50%'}}>
		<TextField
		    id="outlined-multiline-static"
		    label="Compiled Code"
		    multiline
		    fullWidth
		    rows={10} // Adjust the number of rows as needed
		    variant="outlined"
		    value={CompiledCode}
		    readOnly
		/>
        </div>
    )
}
export default Home;
