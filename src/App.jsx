import { useState } from "react";
import reactLogo from "./assets/react.svg";
import aleoLogo from "./assets/aleo.svg";
import "./App.css";
import CanvasGrid from "./CanvasGrid";
import SignalsTable from "./SignalsTable";
import helloworld_program from "../helloworld/build/main.aleo?raw";
import { AleoWorker } from "./workers/AleoWorker.js";

import {
  Account
} from "@aleohq/sdk";

const aleoWorker = AleoWorker();

function Agent(x, y, key) {
  this.x = x;
  this.y = y;
  this.key = key;
  //this.account = Account.fromPrivateKey(key);
}

function Signal(x, y, radius) {
  this.x = x;
  this.y = y;
  this.radius = radius;
}

function App() {
  const [account, setAccount] = useState(null);
  const [executing, setExecuting] = useState(false);
  const [deploying, setDeploying] = useState(false);
  const [selectedAgentKey, setSelectedAgentKey] = useState('');
  const [signalRadius, setSignalRadius] = useState('');
  const [agents, setAgents] = useState([]);
  const [signals, setSignals] = useState([]);

  let state = null;

  const generateAgents = async () => {
    setExecuting(true);
    const key = await aleoWorker.createPrivateKey();

    const result = await aleoWorker.localProgramExecution(
      helloworld_program,
      "init",
      [],
    );

    state = result[0]

    /* const res = await aleoWorker.localProgramExecution(
      helloworld_program,
      "test_state",
      [state],
    ); */

    console.log(state)
    const agents = [];
    for (let i = 0; i < 32; i++) {
      const pk = await aleoWorker.createPrivateKey();
      console.log(pk)
      const pks = await pk.to_string()
      console.log(address)
      const x = Math.floor(Math.random() * 64);
      const y = Math.floor(Math.random() * 64);
      const agent = new Agent(x, y, pks);
      console.log(agent);
      agents.push(agent)

      const res = await aleoWorker.localProgramExecution(
        helloworld_program,
        "register",
        [state, agent.x + "field", agent.y + "field", address],
      );
      state = res[0]
    }

    setAgents(agents);

    setExecuting(false);
  };

  const sendSignal = (agent, radius) => {

    //log agent position 
    console.log("Agent: " + agent + " is at position (" + agent.x + ", " + agent.y + ")")


    // Add a new signal to the signals array
    setSignals(signals => [...signals, { x: agent.x, y: agent.y, radius }]);
    console.log("Sending signal from agent " + agent + " with radius " + radius)
    // ... the rest of your send signal logic
  };

  async function execute(account) {
    setExecuting(true);
    const result = await aleoWorker.localProgramExecution(
      helloworld_program,
      "send_signal",
      ["5u32", "5u32"],
    );
    setExecuting(false);

    alert(JSON.stringify(result));
  }

  async function deploy() {
    setDeploying(true);
    try {
      const result = await aleoWorker.deployProgram(helloworld_program);
      console.log("Transaction:")
      console.log("https://explorer.hamp.app/transaction?id=" + result)
      alert("Transaction ID: " + result);
    } catch (e) {
      console.log(e)
      alert("Error with deployment, please check console for details");
    }
    setDeploying(false);
  }



  return (
    <>
      {/* existing UI elements */}




      <button onClick={generateAgents}>
        Generate Accounts
      </button>
      <label> Radius: </label>
      <input
        type="number"
        value={signalRadius}
        onChange={(e) => setSignalRadius(e.target.value)}
        placeholder="Enter signal radius"
      />


      <div style={{ display: 'flex', justifyContent: 'space-around', padding: '20px' }}>


        <div>      <CanvasGrid agents={agents} signals={signals} /></div>

        {/* Table of Agents */}
        <div>
          {/* Input for signal radius */}

          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                <th style={{ padding: '2px', fontSize: '0.9em' }}>Position</th>
                <th style={{ padding: '2px', fontSize: '0.9em' }}>Address</th>
                <th style={{ padding: '2px', fontSize: '0.9em' }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {agents.map((agent, index) => (
                <tr key={agent.key}>
                  <td style={{ padding: '0px', fontSize: '0.8em' }}>({agent.x}, {agent.y})</td>
                  <td style={{ padding: '0px', fontSize: '0.8em' }}>{agent.key}</td>
                  <td style={{ padding: '0px', fontSize: '0.8em', whiteSpace: 'nowrap' }}>
                    <button
                      onClick={() => sendSignal(agent, signalRadius)}
                      style={{ padding: '0px 0px', fontSize: '0.8em', margin: '0 5px 0 0', display: 'inline-block' }}
                    >
                      Send
                    </button>
                  </td>

                </tr>
              ))}
            </tbody>
          </table>

        </div>

      </div>
      <SignalsTable signals={signals} />

    </>
  );
}

export default App;
