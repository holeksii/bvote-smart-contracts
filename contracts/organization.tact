import "@stdlib/deploy";
import "@stdlib/ownable";
import "./util/organization_messages.tact";
import "./util/metadata.tact";
import "./util/admin.tact";
import "./voting.tact";

contract Organization with Deployable, Ownable {

    const MIN_TON_TO_LIVE: Int = ton("0.1");

    repository: Address;
    organizationId: Int as uint64;
    metadata: Metadata;

    owner: Address;
    numOfVotings: Int as uint64;
    deployVotingFee: Int as uint64;
    lastChanged: Int as uint64;

    init(repository: Address, organizationId: Int) {
        require(sender() == repository, "Only repository can deploy organization");

        self.repository = repository;
        self.organizationId = organizationId;

        self.owner = newAddress(0, 0x0);
        self.numOfVotings = 0;
        self.deployVotingFee = ton("0");
        self.lastChanged = now();

        self.metadata = Metadata{
            name: "",
            description: "",
            emoji: "",
            website: ""
        };
    }

    receive() {}

    receive(msg: InitOrganization) {
        self.owner = msg.owner;
        self.lastChanged = now();

        send(SendParameters{
            to: self.repository,
            value: context().value - self.MIN_TON_TO_LIVE,
            bounce: false,
            mode: 0,
            body: "deployOrgOk".asComment()
        });
    }

    receive(msg: InitOrganizationWithMetadata) {
        self.owner = msg.owner;
        self.metadata = msg.metadata;
        self.lastChanged = now();

        send(SendParameters{
            to: self.repository,
            value: context().value - self.MIN_TON_TO_LIVE,
            bounce: false,
            mode: 0,
            body: "deployOrgOk".asComment()
        });
    }

    receive(msg: UpdateOrganizationInfo) {
        self.requireOwner();
        self.metadata.name = msg.name;
        self.metadata.description = msg.description;
        self.metadata.emoji = msg.emoji;
        self.metadata.website = msg.website;
        self.lastChanged = now();
    }

    receive(msg: DeployVoting) {
        require(context().value >= self.deployVotingFee + self.MIN_TON_TO_LIVE, "Not enough value to deploy voting");

        let stime: Int = msg.startTime;
        if (stime == 0) {
            stime = now();
        } else {
            require(stime > now(), "Start time should be in the future");
        }

        let init: StateInit = initOf Voting(myAddress(), self.numOfVotings);
        let voting: Address = contractAddress(init);

        send(SendParameters{
            to: voting, 
            value: 0, 
            bounce: false,
            mode: SendRemainingValue,
            body: InitVoting{
                owner: sender(),
                candidates: msg.candidates,
                voteFee: msg.voteFee,
                votesPerCandidate:
                msg.votesPerCandidate,
                startTime: stime,
                timeToLive: msg.timeToLive
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive(msg: DeployVotingWithMetadata) {
        require(context().value >= self.deployVotingFee + self.MIN_TON_TO_LIVE, "Not enough value to deploy voting");

        let init: StateInit = initOf Voting(myAddress(), self.numOfVotings);
        let voting: Address = contractAddress(init);

        send(SendParameters{
            to: voting, 
            value: 0, 
            bounce: false,
            mode: SendRemainingValue,
            body: InitVotingWithMetadata{
                owner: sender(),
                candidates: msg.candidates,
                voteFee: msg.voteFee,
                votesPerCandidate: msg.votesPerCandidate,
                startTime: msg.startTime,
                timeToLive: msg.timeToLive,
                metadata: msg.metadata
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive("deployVotingOk") {
        self.numOfVotings += 1;
        self.lastChanged = now();
    }

    receive(msg: SetDeployVotingFee) {
        self.requireOwner();
        self.deployVotingFee = msg.newFee;
    }

    receive(msg: TransferOwnership) {
        self.requireOwner();
        self.owner = msg.newOwner;
    }

    receive("withdrawAll"){
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: 0,
            mode: (SendRemainingBalance + SendIgnoreErrors)
        });
    }

    receive("withdrawSafe"){
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - self.MIN_TON_TO_LIVE,
            mode: 0
        });
    }

    receive(msg: Withdraw) {
        require(sender() == self.owner, "Only deployer is allowed to withdraw");
        let amount: Int = min(msg.amount, myBalance() - context().value - self.MIN_TON_TO_LIVE);
        require(amount > 0, "Insufficient balance");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: amount,
            mode: SendRemainingValue + SendIgnoreErrors
        });
    }

    get fun numOfVotings(): Int {
        return self.numOfVotings;
    }

    get fun deployVotingFee(): Int {
        return self.deployVotingFee;
    }

    get fun deployVotingFeePlusTonToLive(): Int {
        return self.deployVotingFee + self.MIN_TON_TO_LIVE;
    }

    get fun lastChanged(): Int {
        return self.lastChanged;
    }

    get fun metadata(): Metadata {
        return self.metadata;
    }

    get fun organizationId(): Int {
        return self.organizationId;
    }

    get fun repository(): Address {
        return self.repository;
    }

    get fun votingAddress(votingId: Int): Address {
        let init: StateInit = initOf Voting(myAddress(), votingId);
        return contractAddress(init);
    }

    get fun lastVotingAddress(votingId: Int): Address {
        let init: StateInit = initOf Voting(myAddress(), self.numOfVotings - 1);
        return contractAddress(init);
    }

    get fun basicInfo(): OrganizationBasicInfo {
        return OrganizationBasicInfo{
            emoji: self.metadata.emoji,
            name: self.metadata.name,
            website: self.metadata.website
        };
    }

    get fun allInfo(): OrganizationAllInfo {
        return OrganizationAllInfo{
            owner: self.owner,
            emoji: self.metadata.emoji,
            name: self.metadata.name,
            description: self.metadata.description,
            website: self.metadata.website,
            numOfVotings: self.numOfVotings
        };
    }
}
