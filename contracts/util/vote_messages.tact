import "./arrays.tact";

message CastVote {
    owner: Address;
    candidateInd: Int as uint8;
    numOfVotes: Int as uint8;
}
