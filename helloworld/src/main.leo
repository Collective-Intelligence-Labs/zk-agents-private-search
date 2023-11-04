// The 'helloworld' program.
program helloworld.aleo {



    record State {
        agents: [Agent; 32],
        owner: address
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

    transition register(state: State, public x: u32, public y: u32, sender: address) -> (State, AgentRegistered) {
        let e: AgentRegistered = AgentRegistered {
            identity: Identity {
                x: x,
                y: y
            },
            owner: sender
        };
        return (state, e) then finalize(x,y,sender);
    }

    finalize register(public x: u32, public y: u32, sender: address){
        Mapping::set(agents, sender, Agent {
            identity: Identity {
                x: x,
                y: y
            },
            addr: sender
        });
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
