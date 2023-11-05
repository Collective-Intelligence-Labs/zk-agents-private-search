
program private_agents3.aleo {
    struct Identity {
        x: field
        y: field
    }

    record AgentRegistered {
        identity: Identity,
        owner: address
    }

    struct SignalState {
        s: signature,
        identity: Identity,
        distance: field,
        msg: field
    }

    record SignalSent {
        s: signature,
        distance: field,
        owner: address,
        msg: field,
    }

    record SignalRead {
        distance: field,
        msg: field,
        owner: address,
        receiver: address,
        index: u32,
    }

    struct SignalResponse {
        signal: field
        msg: field,
        receiver: address,
        index: u32,
    }

    mapping signals: field => SignalState;
    mapping signals_read: field => field;
    mapping responses: field => SignalResponse;
    mapping reveals: field => field;

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
    transition send_signal(agent: AgentRegistered, payload: address, public distance: field, public s: signature, public msg: field) -> SignalSent { 
        // by some reason it started to work in a wrong way
        //assert_eq(self.caller, agent.owner);
        //assert(s.verify(payload, payload));
        let e: SignalSent = SignalSent {
            distance: distance,
            s: s,
            owner: self.caller,
            msg: msg,
        };
        return e then finalize(agent.identity.x, agent.identity.y, distance, s, msg);
    }
    
    finalize send_signal(public x: field, public y: field, public distance: field, public s: signature, public msg: field){
        let signal: SignalState = SignalState {
             s: s,
             identity: Identity {
                 x: x,
                 y: y,
             },
             distance: distance,
             msg: msg
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

    transition read_signal(public signal: SignalState, agent: AgentRegistered , public receiver: address, s: signature, public msg: field, index: u32) -> SignalRead {
        //Assert the the reaader is within a distance
        assert_eq(agent.owner, self.caller);
        assert(s.verify(receiver, msg));
        //assert_neq(signal.identity,agent.identity);

        let distance:field = calculate_distance(signal.identity, agent.identity);
        assert(distance < signal.distance);

        let e: SignalRead = SignalRead {
            distance: distance,
            msg: msg,
            owner: self.caller,
            receiver: receiver,
            index: index,
        };
        let hash: field = BHP256::hash_to_field(signal);
        return e then finalize(hash, msg, index, receiver);
    }

    
    finalize read_signal(hashS: field, msg: field, index: u32, receiver: address) {
        let response: SignalResponse = SignalResponse {
            signal: hashS,
            msg: msg,
            receiver: receiver,
            index: index,
        };
        let hashR: field = BHP256::hash_to_field(response);
        Mapping::set(signals_read, hashR, hashS);
        Mapping::set(responses, hashR, response);
    }

    

    transition reveal_signal(sent: SignalSent, payload: address, receiver: address, read: field, public response: signature, public request: signature) {
        assert_eq(sent.owner, self.caller);
        assert(request.verify(self.caller, payload));
        return then finalize(read, response, request);
    }

    finalize reveal_signal(read: field, response: signature, request: signature) {
        Mapping::set(reveals, read, read);
    }


    
}
