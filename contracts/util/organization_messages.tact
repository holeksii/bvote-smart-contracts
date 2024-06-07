import "./metadata.tact";
import "./arrays.tact";

message InitOrganization {
    owner: Address;
}

message InitOrganizationWithMetadata {
    owner: Address;
    metadata: Metadata;
}

message UpdateOrganizationInfo {
    emoji: String;
    name: String;
    description: String;
    website: String;
}

message DeployVoting {
    candidates: CandidateArray;
    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;
}

message DeployVotingWithMetadata {
    candidates: CandidateArray;
    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;
    metadata: Metadata;
}

message SetDeployVotingFee {
    newFee: Int as uint64;
}

struct OrganizationBasicInfo {
    emoji: String;
    name: String;
    website: String;
}

struct OrganizationAllInfo {
    owner: Address;
    emoji: String;
    name: String;
    description: String;
    website: String;
    numOfVotings: Int as uint64;
}
