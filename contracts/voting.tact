import "@stdlib/deploy";
import "@stdlib/ownable";
import "./util/arrays.tact";
import "./util/metadata.tact";
import "./util/voting_messages.tact";
import "./util/vote_messages.tact";
import "./util/admin.tact";
import "./vote.tact";

contract Voting with Deployable, Ownable {

    const MIN_TON_TO_LIVE: Int = ton("0.1");

    owner: Address;
    organization: Address;
    votingId: Int as uint64;
    candidates: CandidateArray;
    metadata: Metadata;

    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;

    init(organization: Address, votingId: Int) {
        require(sender() == organization, "Only the organization can deploy the voting contract");

        self.owner =  newAddress(0, 0x0);
        self.organization = organization;
        self.votingId = votingId;
        self.candidates = CandidateArray{size: 0, candidates: emptyMap()};

        self.voteFee = ton("0");
        self.votesPerCandidate = 0;
        self.startTime = 0;
        self.timeToLive = 0;

        self.metadata = Metadata{
            name: "",
            description: "",
            emoji: "",
            website: ""
        };
    }

    receive() {}

    receive(msg: InitVoting) {
        self.owner  = msg.owner;
        self.candidates = msg.candidates;
        self.voteFee = msg.voteFee;
        self.votesPerCandidate = msg.votesPerCandidate;
        self.startTime = msg.startTime;
        self.timeToLive = msg.timeToLive;

        send(SendParameters{
            to: self.organization,
            value: context().value - self.MIN_TON_TO_LIVE,
            bounce: false,
            mode: 0,
            body: "deployVotingOk".asComment()
        });
    }

    receive(msg: InitVotingWithMetadata) {
        self.owner  = msg.owner;
        self.candidates = msg.candidates;
        self.voteFee = msg.voteFee;
        self.votesPerCandidate = msg.votesPerCandidate;
        self.startTime = msg.startTime;
        self.timeToLive = msg.timeToLive;
        self.metadata = msg.metadata;

 
        send(SendParameters{
            to: self.organization,
            value: context().value - self.MIN_TON_TO_LIVE,
            bounce: false,
            mode: 0,
            body: "deployVotingOk".asComment()
        });
    }

    receive(msg: DeployAndCastVote) {
        require(now() >= self.startTime, "Voting has not started yet");
        require(now() <= self.startTime + self.timeToLive, "Voting has ended");

        require(msg.numOfVotes <= self.votesPerCandidate, "Invalid number of votes");
        let totalFee: Int = self.voteFee * msg.numOfVotes;
        require(context().value > totalFee, "Insufficient funds");

        let init: StateInit = initOf Vote(myAddress(), sender());
        let voting: Address = contractAddress(init);
        
        send(SendParameters{
            to: voting,
            value: context().value - totalFee,
            bounce: false,
            mode: 0,
            body: CastVote{
                owner: sender(),
                candidateInd: msg.candidateInd,
                numOfVotes: msg.numOfVotes
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive(msg: DeployAndCastVoteOk) {
        let cand: Candidate = self.candidates.candidates.get(msg.candidateInd)!!;
        self.candidates.candidates.set(msg.candidateInd, Candidate{
            name: cand.name,
            info: cand.info,
            votes: cand.votes + msg.numOfVotes
        });

        send(SendParameters{
            to: msg.voter,
            bounce: true,
            value: 0,
            mode: (SendRemainingValue + SendIgnoreErrors)
        });
    }

    receive(msg: TransferOwnership) {
        self.requireOwner();
        self.owner = msg.newOwner;
    }

    receive("withdrawAll") {
        self.requireOwner();
        require(now() >= self.startTime + self.timeToLive, "Voting has not ended yet");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: 0,
            mode: (SendRemainingBalance + SendIgnoreErrors)
        });
    }

    receive("withdrawSafe") {
        self.requireOwner();
        require(now() >= self.startTime + self.timeToLive, "Voting has not ended yet");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - self.MIN_TON_TO_LIVE,
            mode: 0
        });
    }

    get fun organization(): Address {
        return self.organization;
    }

    get fun votingId(): Int {
        return self.votingId;
    }

    get fun candidates(): CandidateArray {
        return self.candidates;
    }

    get fun numOfVotes(): Int {
        let num: Int = 0;
        let i: Int = 0;
        while (i < self.candidates.size) {
            if (self.candidates.candidates.get(i) != null) {
                let candidate: Candidate = self.candidates.candidates.get(i)!!;
                num += candidate.votes;
            }
            i += 1;
        }

        return num;
    }

    get fun voteFee(): Int {
        return self.voteFee;
    }

    get fun votesPerCandidate(): Int {
        return self.votesPerCandidate;
    }

    get fun startTime(): Int {
        return self.startTime;
    }

    get fun timeToLive(): Int {
        return self.timeToLive;
    }

    get fun metadata(): Metadata {
        return self.metadata;
    }

    get fun voteAddress(owner: Address): Address {
        let init: StateInit = initOf Vote(myAddress(), owner);
        let voting: Address = contractAddress(init);

        return voting;
    }

    get fun basicInfo(): VotingBasicInfo {
        return VotingBasicInfo{
            emoji: self.metadata.emoji,
            name: self.metadata.name,
            startTime: self.startTime,
            endTime: self.startTime + self.timeToLive
        };
    }

    get fun allInfo(): VotingAllInfo {
        return VotingAllInfo{
            organization: self.organization,
            owner: self.owner,
            emoji: self.metadata.emoji,
            name: self.metadata.name,
            description: self.metadata.description,
            numOfVotes: self.numOfVotes(),
            voteFee: self.voteFee,
            votesPerCandidate: self.votesPerCandidate,
            startTime: self.startTime,
            endTime: self.startTime + self.timeToLive
        };
    }
}
