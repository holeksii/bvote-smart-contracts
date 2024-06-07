import "./metadata.tact";
import "./arrays.tact";

message InitVoting {
    owner: Address;
    candidates: CandidateArray;
    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;
}

message InitVotingWithMetadata {
    owner: Address;
    candidates: CandidateArray;
    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;
    metadata: Metadata;
}

message DeployAndCastVote {
    candidateInd: Int as uint8;
    numOfVotes: Int as uint8;
}

message DeployAndCastVoteOk {
    voter: Address;
    candidateInd: Int as uint8;
    numOfVotes: Int as uint8;
}

struct VotingBasicInfo {
    emoji: String;
    name: String;
    startTime: Int as uint64;
    endTime: Int as uint64;
}

struct VotingAllInfo {
    organization: Address;
    owner: Address;
    emoji: String;
    name: String;
    description: String;
    numOfVotes: Int as uint64;
    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    endTime: Int as uint64;
}
