import "@stdlib/deploy";
import "@stdlib/ownable";
import "./util/arrays.tact";
import "./util/metadata.tact";
import "./util/voting_messages.tact";
import "./util/vote_messages.tact";
import "./vote.tact";

contract HiddenVoting with Deployable, Ownable {

    const MIN_TON_TO_LIVE: Int = ton("0.1");

    owner: Address;
    candidates: CandidateArray;
    metadata: Metadata;

    voteFee: Int as uint64;
    votesPerCandidate: Int as uint8;
    startTime: Int as uint64;
    timeToLive: Int as uint64;

    init(
        organization: Address,
        candidates: CandidateArray,
        voteFee: Int,
        votesPerCandidate: Int,
        startTime: Int,
        timeToLive: Int,
        metadata: Metadata
    ) {
        require(sender() == organization, "Only the organization can deploy the voting contract");

        self.owner = sender();
        self.candidates = candidates;

        self.voteFee = voteFee;
        self.votesPerCandidate = votesPerCandidate;
        self.startTime = startTime;
        self.timeToLive = timeToLive;

        self.metadata = metadata;
    }

    receive() {}

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

    receive("withdrawAll") {
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: 0,
            mode: (SendRemainingBalance + SendIgnoreErrors)
        });
    }

    receive("withdrawSafe") {
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - self.MIN_TON_TO_LIVE,
            mode: 0
        });
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
            organization: self.owner,
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
