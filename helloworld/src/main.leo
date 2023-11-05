// The 'helloworld' program.
program private_agents.aleo {


    struct Identity {
        x: field
        y: field
    }

    record AgentRegistered {
        identity: Identity,
        owner: address
    }

    struct SignalState {
        signal_encrypted: u32,
        identity: Identity,
        distance: field,
    }

    record SignalSent {
        signal_encrypted: u32,
        distance: field,
        owner: address,
    }

    record SignalRead {
        signal: u32,
        distance: field,
        owner: address,
    }

    mapping signals: field => SignalState;

    transition register(x: field, y: field) -> AgentRegistered {
        let e: AgentRegistered = AgentRegistered {
            identity: Identity {
                x: x,
                y: y
            },
            owner: self.caller
        };
        return e;
    }
    
    //Sends a signal (a data) to a specifc agents in the network that are within a certain radius of the sender, here it just stores it in the mapping and does not send it to the agent agents read it in the next transition
    transition send_signal(agent: AgentRegistered, public distance: field, public signal_encrypted: u32 ) -> SignalSent{
        
        assert_eq(self.caller, agent.owner);
        let e: SignalSent = SignalSent {
            distance: distance,
            signal_encrypted: signal_encrypted,
            owner: self.caller
        };
        return e then finalize(agent.identity, distance, signal_encrypted);
    }
    
    finalize send_signal(public id: Identity, public distance: field, public signal_encrypted: u32){
        let signal: SignalState = SignalState {
             signal_encrypted: signal_encrypted,
             identity: id,
             distance: distance,
        };
        let hash: field = BHP256::hash_to_field(signal);
        Mapping::set(signals, hash, signal);
    }

    //TODO:
    //
     function calculate_distance(id1: Identity, id2: Identity) -> field {
        let field1:field = id2.x - id1.x;
        let field2:field = id2.y - id1.y;
        let distanceSquared:field = field1.square() + field2.square();
        let distance:field = distanceSquared.square_root();
        return distance;
    }
    //Allows to read signal if the sender is within the radius of the signal
    transition read_signal( public signal: SignalState, agent: AgentRegistered ) -> SignalRead {
        //Assert the the reaader is within a distance

        assert_neq(signal.identity,agent.identity);

        let distance:field = calculate_distance(signal.identity, agent.identity);
        assert(distance < signal.distance);
        
        return SignalRead {
            signal: signal.signal_encrypted,
            distance: distance,
            owner: self.caller
        };
    }

    //finalize read_signal(signal: u32, sender: address){
    //    Mapping::remove(signals, signal);
    //}
    
   
    

    
}
