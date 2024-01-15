import React from 'react';
import { useState } from 'react';
import Editor from "@monaco-editor/react";
import Button from '@mui/material/Button';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import InputLabel from '@mui/material/InputLabel';
import FormControl from '@mui/material/FormControl';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import Lisp from '../assets/lisp2.png';
import Haskell from '../assets/haskell.png';
import Racket from '../assets/racket.png';
import SICP from '../assets/sicp.jpg';
import { styled } from '@mui/material/styles'
const lispUrl = "http://localhost:4243/"

const StyledImg = styled('img')(({ theme }) => ({
    marginRight: theme.spacing(10),
    width: '80%',
    height: '500px',
}));

const images = [Lisp, SICP]
function Home() {
    const [ExpCode, setExpCode] = useState("");
    const [CompiledCode, setCompiledCode] = useState("")
    const [comp, setComp] = React.useState(null);
    const [url, setUrl] = React.useState("")
    const [user, setUser] = React.useState("")

    const handleChange = (event) => {
	setComp(event.target.value);
    }
   

    const CpsHandle = () => {
        setUrl("cps-compilations")
        
    }

    const ScmHandle = () => {
        setUrl("scm-compilations")
    }

    const PyHandle = () => {
        setUrl("py-compilations")
    }

    const LalgHandle = () => {
        setUrl("lalg-compilations")
    }

    const scm = "Scheme to Lambda compiler"

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
	
	<div style={{ backgroundColor: '#989898', padding: '20px' }}>
            <Grid container spacing={2}>
		<Grid item>
		    <FormControl fullWidth>
			<InputLabel
			sx={{
                                color: 'white', // Set label color to white
                            }}
			>Compilers</InputLabel>
		    <Select
			label="Compilers"
			value={comp}
		    onChange={handleChange}
			sx={{
			    width: 250,
			    height: 50,
			    backgroundColor: 'black',
			    color: 'white',
			}}>
		 
			<MenuItem value={1} onClick={CpsHandle}>CPS Compiler</MenuItem>
			<MenuItem value={2} onClick={ScmHandle}>Scheme to Lambda compiler</MenuItem>
			<MenuItem value={3} onClick={PyHandle}>Py compiler</MenuItem>
			<MenuItem value={4} onClick={LalgHandle}> Lalg Compiler</MenuItem>
		    </Select>
			</FormControl>
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
			     InputLabelProps={{
                                style: { color: 'white' }, // Set label color to white
                            }}
			     sx={{
                                backgroundColor: 'black',
				 '& input': {
                                    color: 'white', 
                                },
                            }}
			/>
		    </Box>
		</Grid>
	    </Grid>
	   
		    <Editor height="calc(50vh - 25px)"  theme="vs-dark" onChange={(val) => {setExpCode(val)}}/>
	    <Button
		onClick={Compile}
		variant="contained"
	         sx={{
                    backgroundColor: 'black', // Set black background
                    color: 'white', // Set text color to white
                    '&:hover': {
                        backgroundColor: 'darkgray', // Set a different color on hover if desired
                    },
                }}>Compile Exp</Button>
		
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
			sx={{
			    backgroundColor: 'black',
			    color: 'white',
			    '& .MuiInputLabel-root, & .MuiOutlinedInput-notchedOutline, & .MuiInputBase-input': {
                            color: 'white', // Set label, border, and text color to white
                        },
			    
			}}
			   
		    />
		</div>
		
	    </div>
	    )}
	    export default Home;
