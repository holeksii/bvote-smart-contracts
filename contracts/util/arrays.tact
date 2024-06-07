struct Candidate {
    name: String;
    info: String;
    votes: Int as uint64;
}

struct CandidateArray {
    size: Int as uint8;
    candidates: map<Int as uint64, Candidate>; // candidateId -> candidate
}
