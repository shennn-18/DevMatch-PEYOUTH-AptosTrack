module dvs_address::DVS {
    use std::string::String;
    use aptos_std::table::Table; // Correctly import Vector

    struct Host has key {
        candidates: Table<u64, Candidate>,
        voting_active: bool,
        tac: u64,
        end_time: u64,
    }

    struct Candidate has key,store {
        name: String,
        id: u64,
        votes: u64,
    }

    struct Voter has key {
        has_voted: bool,
        verified_tac: bool,
    }

}
