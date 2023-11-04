// The 'helloworld' program.
program helloworld.aleo {



    record State {
        agents_x: [u32; 32],
        agents_y: [u32; 32],
        agents_address: [address; 32],
        owner: address
        counter: u32
    }

    struct Identity {
        x: u32
        y: u32
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
    transition new_map_state(
    ) -> State {
        let default_array: [u32; 32] = [0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32,0u32];
        let a:address = aleo1ezamst4pjgj9zfxqq0fwfj8a4cjuqndmasgata3hggzqygggnyfq6kmyd4;
        let default_addrs: [address; 32] = [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a];
        return State {
            agents_x: default_array,
            agents_y: default_array,
            agents_address: default_addrs,
            owner: self.signer,
            counter: 0u32
        };
    }

    function update_state(s: State, x: u32, y: u32, sender: address) -> State {
        let agents_x:[u32; 32] = s.agents_x;
        let agents_y:[u32; 32] = s.agents_y;
        let agents_addresses:[address; 32] = s.agents_address;
        let new_counter:u32 = s.counter + 1u32;
        agents_x[s.counter] = x;
        agents_y[s.counter] = y;
        agents_addresses[s.counter] = sender;

        return State {
            agents_x: agents_x,
            agents_y: agents_y,
            agents_address: agents_addresses,
            owner: self.signer,
            counter: 0u32
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
        let new_state:State = update_state(state, x, y, sender);
        return (new_state, e);
    }

    struct Signal {
        signal: u32,
        radius: u32,
        sender: address
    }

    mapping signals: u32 => Signal;

    record SignalSent {
        signal: u32,
        radius: u32,
        owner: address,
    }
    
    //Sends a signal (a data) to a specifc agents in the network that are within a certain radius of the sender, here it just stores it in the mapping and does not send it to the agent agents read it in the next transition
    transition send_signal(radius: u32, sender: address, signal: u32 ) -> SignalSent{
        let e: SignalSent = SignalSent {
            signal: signal,
            radius: radius,
            owner: sender
        };
        return e then finalize(radius, sender, signal);
    }

    finalize send_signal(radius: u32, sender: address, signal: u32 ) {
        Mapping::set(signals, signal, Signal {
                signal: signal,
                radius: radius,
                sender: sender
        });
    }

    record SignalRead {
        signal: u32,
        radius: u32,
        owner: address,
        reader: address,
    }


    //Allows to read signal if the sender is within the radius of the signal
    transition read_signal(s: State, signal: u32, sender: address) -> (State, SignalRead) {
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
