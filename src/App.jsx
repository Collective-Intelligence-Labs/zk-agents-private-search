import { useState  } from "react";
import reactLogo from "./assets/react.svg";
import aleoLogo from "./assets/aleo.svg";
import "./App.css";
import CanvasGrid from "./CanvasGrid";
import SignalsTable from "./SignalsTable";
import private_agents from "../private_agents/build/main.aleo?raw";
import { AleoWorker } from "./workers/AleoWorker.js";
import {
  Account, PrivateKey
} from "@aleohq/sdk";


const aleoWorker = AleoWorker();

function Agent(x, y, key) {
  this.x = x;
  this.y = y;
  this.key = key;
  this.registration = null;
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
  const [agentsToCreate, setAgentsToCreate] = useState('32');
  const [agents, setAgents] = useState([]);
  const [signals, setSignals] = useState([]);

  let state = null;
  
  
  const createAgent = async (aleoWorker, private_agents) => {
    const pk = await aleoWorker.createPrivateKey();
    console.log(pk);
    const pks = await pk.to_string();
    const x = Math.floor(Math.random() * 64);
    const y = Math.floor(Math.random() * 64);
    const agent = new Agent(x, y, pks);
    console.log(agent);
  
    const res = await aleoWorker.localProgramExecution(
      private_agents,
      "register",
      [x + "field", y + "field"],
      pks
    );
    agent.registration = res[0];
    console.log(agent)
    return agent;
  };

 
// Inside your function/component
const generateAgents = async () => {
  try {
    const agentPromises = [];
    for (let i = 0; i < agentsToCreate; i++) {
      agentPromises.push(createAgent(aleoWorker, private_agents));
    }
    const newAgents = await Promise.all(agentPromises);

    // Now you have all the newAgents created in parallel
    setAgents(agents => [...agents, ...newAgents]);
  } catch (error) {
    console.error('An error occurred while creating agents:', error);
  }
};

  const sendSignal = async (agent, radius) => {

    //log agent position 
    console.log(agent);

    //log agent key

    const sKey = new PrivateKey();
    console.log(sKey);
    const addr = sKey.to_address().to_string();
    const sign = (await sKey.sign(addr)).to_string();
    console.log(sign);

    const res = await aleoWorker.localProgramExecution(
      private_agents,
      "send_signal",
      [agent.registration, addr, radius + "field", sign, 4343 + "field" ],
      agent.key
    );

    // Add a new signal to the signals array
    setSignals(signals => [...signals, { x: agent.x, y: agent.y, radius }]);
    console.log("Sending signal from agent " + agent + " with radius " + radius)
    // ... the rest of your send signal logic
  };

  async function execute(account) {
    setExecuting(true);
    const result = await aleoWorker.localProgramExecution(
      private_agents,
      "send_signal",
      ["5u32", "5u32"],
    );
    setExecuting(false);

    alert(JSON.stringify(result));
  }

  async function deploy() {
    setDeploying(true);
    try {
      const result = await aleoWorker.deployProgram(private_agents);
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
      <input
        type="number"
        value={agentsToCreate}
        onChange={(e) => setAgentsToCreate(e.target.value)}
        placeholder="Enter signal distance"
      />

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
              

      <button onClick={deploy}>
        Deploy Smart Contract
      </button>
    </>
  );
}

export default App;
