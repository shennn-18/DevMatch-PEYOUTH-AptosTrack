module dvs_address::DVS {
    use std::string::String;
    use aptos_std::table::{Self, Table};
    use std::signer;
    use std::timestamp;

    // ERRORS
    const E_HOST_EXISTS: u64 = 1;
    const E_NOT_HOST: u64 = 2;
    const E_ALREADY_EXISTS: u64 = 3;
    const E_VOTING_ALREADY_ACTIVE: u64 = 4;
    const E_VOTING_NOT_ACTIVE: u64 = 5;

    struct Host has key, store {
        deployer: address, // Store the deployer's address
        candidates: Table<u64, Candidate>,
        voting_active: bool,
        tac_list: Table<u64, bool>,
        end_time: u64,
    }

    struct Candidate has key, store, drop {
        name: String,
        id: u64,
        votes: u64,
    }

    struct Voter has key {
        has_voted: bool,
        verified_tac: bool,
    }

    // Ensure that the contract deployer's address is the signer's  
    public entry fun initializeDVS(account: &signer) {
        // Get the deployer's address
        let deployer_address = signer::address_of(account);

        // Check if the Host resource already exists
        assert!(!exists<Host>(deployer_address), E_HOST_EXISTS);

        // Create a new Host instance with default values
        let host = Host {
            deployer: deployer_address,
            candidates: table::new(),
            voting_active: false,
            tac_list: table::new(),
            end_time: 0
        };

        // Store the Host instance in the account's resources
        move_to(account, host);
    }

    // Function for host to add candidates
    public entry fun add_candidate(account: &signer, id: u64, name: String) acquires Host {
        // Ensure that only the Host (deployer) can add candidates
        let deployer_address = signer::address_of(account);
        let host = borrow_global_mut<Host>(deployer_address);
        assert!(deployer_address == host.deployer, E_NOT_HOST);

        // Check if the candidate ID already exists
        assert!(!table::contains<u64, Candidate>(&host.candidates, id), E_ALREADY_EXISTS);

        // Create a new Candidate instance
        let candidate = Candidate {
            name: name,
            id: id,
            votes: 0
        };

        // Store the Candidate in the Host's candidates table
        table::upsert(&mut host.candidates, id, candidate);
    }

    // Function to start voting
    public entry fun start_voting(account: &signer, duration: u64) acquires Host {
        let deployer_address = signer::address_of(account);
        let host = borrow_global_mut<Host>(deployer_address);
        assert!(deployer_address == host.deployer, E_NOT_HOST);

        // Check if voting is already active
        assert!(!host.voting_active, E_VOTING_ALREADY_ACTIVE);

        // Start Voting
        let current_time = timestamp::now_seconds(); // Get current time in seconds
        host.voting_active = true;
        host.end_time = current_time + duration;
    }

    // Function to end voting
    public entry fun end_voting(account: &signer) acquires Host {
        let deployer_address = signer::address_of(account);
        let host = borrow_global_mut<Host>(deployer_address);
        assert!(deployer_address == host.deployer, E_NOT_HOST);

        // Check if voting is active
        assert!(host.voting_active, E_VOTING_NOT_ACTIVE);

        // End Voting
        host.voting_active = false;
        host.end_time = timestamp::now_seconds(); // Set end time to current time
    }

    // Set TAC for voting process, which will be used for TAC verification for voters
    public entry fun set_tac(account: &signer, tac: u64) acquires Host {
        let deployer_address = signer::address_of(account);
        let host = borrow_global_mut<Host>(deployer_address);
        assert!(deployer_address == host.deployer, E_NOT_HOST);

        // Set the TAC
        table::upsert(&mut host.tac_list, tac, true);
    }


}
