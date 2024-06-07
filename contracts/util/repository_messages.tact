import "./metadata.tact";

message DeployOrganizationWithMetadata {
    metadata: Metadata;
}

message SetDeployOrgFee {
    newFee: Int as uint64;
}
