// The 'helloworld' program.
program helloworld.aleo {


    struct Identity {
        x: field
        y: field
    }

    record AgentRegistered {
        identity: Identity,
        owner: address
    }

    struct SignalState {
        signal_encrupted: u32,
        identity: Identity,
        distance: u32,
    }

    record SignalSent {
        signal_encrypted: u32,
        distance: u32,
        owner: address,
    }

    record SignalRead {
        signal: u32,
        radius: u32,
        owner: address,
        reader: address,
    }

    mapping signals: field => SignalState;

    transition register(public id: Identity) -> AgentRegistered {
        let e: AgentRegistered = AgentRegistered {
            identity: id,
            owner: self.caller
        };
        return e;
    }
    
    //Sends a signal (a data) to a specifc agents in the network that are within a certain radius of the sender, here it just stores it in the mapping and does not send it to the agent agents read it in the next transition
    transition send_signal(agent: AgentRegistered, public distance: u32, public signal_encrypted: u32 ) -> SignalSent{
        
        assert_eq(self.caller, agent.owner);
        let e: SignalSent = SignalSent {
            distance: distance,
            signal_encrypted: signal_encrypted,
            owner: self.caller
        };
        return e then finalize(agent.identity, distance, signal_encrypted);
    }
    
    finalize send_signal(public id: Identity, public distance: u32, public signal_encrypted: u32){
        let signal: SignalState = SignalState {
             signal_encrupted: signal_encrypted,
             identity: id,
             distance: distance,
        };
        let hash: field = BHP256::hash_to_field(signal);
        Mapping::set(signals, hash, signal);
    }

    //TODO:
    //

    //Allows to read signal if the sender is within the radius of the signal
    transition read_signal( public signal: SignalState, agent: AgentRegistered ) -> SignalRead {
        //Assert the the reaader is within a distance

        assert_neq(signal.identity,agent.identity);

        let distance = calculate_distance(signal.identity, agent.identity)
        assert(distance < signal.distance);
        
        return SignalRead {
            signal: signal,
            distance: distance,
            reader: self.caller;
        }
    }

    //finalize read_signal(signal: u32, sender: address){
    //    Mapping::remove(signals, signal);
    //}
    
    function calculate_distance(public id1: Identity, public id2: Identity): field {
        let field1:field = id2.x - id1.x;
        let field2:field = id2.y - id1.y;
        let distanceSquared:field = field1.square() + field2.square();
        let distance:field = distanceSquared.square_root();
        return distance;
    }
    

    
}
