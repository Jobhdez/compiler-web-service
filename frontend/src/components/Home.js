import { useState } from 'react';
import Editor from "@monaco-editor/react";

const lambdaUrl = "http://localhost:4243/compile?exp=";
const cpsUrl = "http://localhost:4243/cps?exp="

function Home() {
    const [lambdaCode, setLambdaCode] = useState("");
    const [cpsCode, setCpsCode] = useState("")
    const [lambdaCompiledCode, setLambdaCompiledCode] = useState("")
    const [cpsCompiledCode, setCpsCompiledCode] = useState("")

    const lambdaCompile = () => {
        fetch(lambdaUrl+lambdaCode).then((response) => response.json()).then((data)=> {setLambdaCompiledCode(data.expression)})
        console.log(lambdaCompiledCode)
        }
 
    const cpsCompile = async () => {
        fetch(cpsUrl+cpsCode).then((response) => response.json()).then((data)=>{setCpsCompiledCode(data.expression)})
        }
    
    console.log(lambdaCode)
    console.log(lambdaUrl+lambdaCode)
    return (
    
    <div>
        <div>
            
            <Editor height="calc(50vh - 25px)" theme="vs-dark" onChange={(val) => {setLambdaCode(val)}}/>
            <button onClick={lambdaCompile}> compile</button>
            <div>
                <pre>{lambdaCompiledCode}</pre>
            </div>
        </div>  
        
            <div>
                 <Editor height="calc(50vh - 25px)" theme="vs-dark" onChange={(val) => {setCpsCode(val)}}/>
                 <button onClick={cpsCompile}> compile</button>
                 <div>
                    <pre>{cpsCompiledCode}</pre>
                </div>
            </div>
            
            
        </div>
    )
}
export default Home;