module dvs_address::DVS {
    use std::string::String;
    use aptos_std::table::{Self, Table};
    use std::signer;

    struct Host has key, store {
        deployer: address, // Store the deployer's address
        candidates: Table<u64, Candidate>,
        voting_active: bool,
        tac: u64,
        end_time: u64,
    }

    struct Candidate has key, store {
        name: String,
        id: u64,
        votes: u64,
    }

    struct Voter has key {
        has_voted: bool,
        verified_tac: bool,
    }

    // Ensure that the contract deployer's address is the signer's  
    public entry fun initializeDVS (account: &signer) {
        // Get the deployer's address
        let deployer_address = signer::address_of(account);
        
        // Create a new Host instance with default values
        let host = Host {
            deployer: deployer_address,
            candidates: table::new(),
            voting_active: false,
            tac: 0,
            end_time: 0
        };
        
        // Store the Host instance in the account's resources
        move_to(account, host);
    }
}
