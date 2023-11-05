// The 'helloworld' program.
program helloworld.aleo {



    struct State {
        agents_x: [u32; 32],
        agents_y: [u32; 32],
        owner_address: address
        counter: u32
        signals: [Signal; 32]
    }

    struct Identity {
        x: u32
        y: u32
        idk: mapping
    }

    struct Agent {
        identity: Identity,
        addr: address,
    }

    record AgentRegistered {
        identity: Identity,
        owner: address
    }

    mapping agents: address => Agent;

    // Returns a new board_state.
    transition init(
    ) -> State {
        let default_array: [u32; 32] = [0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32];
        
        return State {
            agents_x: default_array,
            agents_y: default_array,
            owner_address: self.signer,
            counter: 0u32
        };
    }

    function update_state_register(s: State, x: u32, y: u32, sender: address) -> State {
        let xs: [u32; 32] = [s.agents_x[0u32],s.agents_x[1u32],s.agents_x[2u32],s.agents_x[3u32],s.agents_x[4u32],s.agents_x[5u32],s.agents_x[6u32],s.agents_x[7u32],s.agents_x[8u32],s.agents_x[9u32],s.agents_x[10u32],s.agents_x[11u32],s.agents_x[12u32],s.agents_x[13u32],s.agents_x[14u32],s.agents_x[15u32],s.agents_x[16u32],s.agents_x[17u32],s.agents_x[18u32],s.agents_x[19u32],s.agents_x[20u32],s.agents_x[21u32],s.agents_x[22u32],s.agents_x[23u32],s.agents_x[24u32],s.agents_x[25u32],s.agents_x[26u32],s.agents_x[27u32],s.agents_x[28u32],s.agents_x[29u32],s.agents_x[30u32],s.agents_x[31u32]];
        let ys: [u32; 32] = [s.agents_y[0u32],s.agents_y[1u32],s.agents_y[2u32],s.agents_y[3u32],s.agents_y[4u32],s.agents_y[5u32],s.agents_y[6u32],s.agents_y[7u32],s.agents_y[8u32],s.agents_y[9u32],s.agents_y[10u32],s.agents_y[11u32],s.agents_y[12u32],s.agents_y[13u32],s.agents_y[14u32],s.agents_y[15u32],s.agents_y[16u32],s.agents_y[17u32],s.agents_y[18u32],s.agents_y[19u32],s.agents_y[20u32],s.agents_y[21u32],s.agents_y[22u32],s.agents_y[23u32],s.agents_y[24u32],s.agents_y[25u32],s.agents_y[26u32],s.agents_y[27u32],s.agents_y[28u32],s.agents_y[29u32],s.agents_y[30u32],s.agents_y[31u32]];
        let new_counter: u32 = s.counter + 1u32;

        return State {
            agents_x: xs,
            agents_y: ys,
            owner_address: self.signer,
            counter: new_counter
        };
    }

    function update_state_signal(s: State, x: u32, y: u32, sender: address) -> State {
        let xs: [u32; 32] = [s.agents_x[0u32],s.agents_x[1u32],s.agents_x[2u32],s.agents_x[3u32],s.agents_x[4u32],s.agents_x[5u32],s.agents_x[6u32],s.agents_x[7u32],s.agents_x[8u32],s.agents_x[9u32],s.agents_x[10u32],s.agents_x[11u32],s.agents_x[12u32],s.agents_x[13u32],s.agents_x[14u32],s.agents_x[15u32],s.agents_x[16u32],s.agents_x[17u32],s.agents_x[18u32],s.agents_x[19u32],s.agents_x[20u32],s.agents_x[21u32],s.agents_x[22u32],s.agents_x[23u32],s.agents_x[24u32],s.agents_x[25u32],s.agents_x[26u32],s.agents_x[27u32],s.agents_x[28u32],s.agents_x[29u32],s.agents_x[30u32],s.agents_x[31u32]];
        let ys: [u32; 32] = [s.agents_y[0u32],s.agents_y[1u32],s.agents_y[2u32],s.agents_y[3u32],s.agents_y[4u32],s.agents_y[5u32],s.agents_y[6u32],s.agents_y[7u32],s.agents_y[8u32],s.agents_y[9u32],s.agents_y[10u32],s.agents_y[11u32],s.agents_y[12u32],s.agents_y[13u32],s.agents_y[14u32],s.agents_y[15u32],s.agents_y[16u32],s.agents_y[17u32],s.agents_y[18u32],s.agents_y[19u32],s.agents_y[20u32],s.agents_y[21u32],s.agents_y[22u32],s.agents_y[23u32],s.agents_y[24u32],s.agents_y[25u32],s.agents_y[26u32],s.agents_y[27u32],s.agents_y[28u32],s.agents_y[29u32],s.agents_y[30u32],s.agents_y[31u32]];
        let new_counter: u32 = s.counter + 1u32;

        return State {
            agents_x: xs,
            agents_y: ys,
            owner_address: self.signer,
            counter: new_counter
        };
    }
    transition register(state: State, public x: u32, public y: u32, sender: address) -> (State, AgentRegistered) {
        let e: AgentRegistered = AgentRegistered {
            identity: Identity {
                x: x,
                y: y
            },
            owner: sender
        };
        let new_state:State = update_state_register(state, x, y, sender);
        return (new_state, e);
    }
    
    struct Signal {
        signal: u32,
        radius: u32,
        x: u32,
        y: u32,
    }

    mapping signals: u32 => Signal;

    record SignalSent {
        signal: u32,
        radius: u32,
        owner: address,
    }
    
    //Sends a signal (a data) to a specifc agents in the network that are within a certain radius of the sender, here it just stores it in the mapping and does not send it to the agent agents read it in the next transition
    transition send_signal(radius: u32, sender: address, signal: u32, agent:AgentRegistered ) -> SignalSent{
        assert_eq(sender, agent.owner);
        let e: SignalSent = SignalSent {
            signal: signal,
            radius: radius,
            owner: sender
        };
        return e;
    }

    record SignalRead {
        signal: u32,
        radius: u32,
        owner: address,
        reader: address,
    }


    //Allows to read signal if the sender is within the radius of the signal
    transition read_signal(s: State, signal: u8, sender: address, agent:AgentRegistered) -> (State, SignalRead) {
        assert_eq(sender, agent.owner);
        let e: SignalRead = SignalRead {
            signal: signal,
            radius: s.radius,
            owner: s.owner,
            reader: sender
        };
        return (s, e) then finalize(signal, sender);
    }

    finalize read_signal(signal: u32, sender: address){
        Mapping::remove(signals, signal);
    }
    
}
