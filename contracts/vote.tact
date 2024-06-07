import "@stdlib/deploy";
import "@stdlib/ownable";
import "./util/arrays.tact";
import "./util/voting_messages.tact";
import "./util/vote_messages.tact";

contract Vote with Deployable, Ownable {
    
    owner: Address;
    voting: Address;
    candidateInd: Int as uint8;
    numOfVotes: Int as uint8;

    init(voting: Address, owner: Address) {
        require(sender() == voting, "Only the voting contract can deploy this contract");

        self.owner = owner;
        self.voting = voting;
        self.candidateInd = -1;
        self.numOfVotes = 0;
    }

    receive(msg: CastVote) {
        let isOwner: Bool = msg.owner == self.owner;
        let noVotes: Bool = self.numOfVotes == 0;

        if (!(isOwner && noVotes)) {
            send(SendParameters{
                to: self.owner,
                value: 0,
                bounce: true,
                mode: SendRemainingValue
            });
        }

        require(noVotes, "Votes already casted");
        require(isOwner, "Only the owner can cast votes");
        self.owner = msg.owner;
        self.candidateInd = msg.candidateInd;
        self.numOfVotes = msg.numOfVotes;

        self.reply(DeployAndCastVoteOk{
            voter: self.owner,
            candidateInd: msg.candidateInd,
            numOfVotes: msg.numOfVotes
        }.toCell());
    }

    get fun voting(): Address {
        return self.voting;
    }

    get fun candidateInd(): Int {
        return self.candidateInd;
    }

    get fun numOfVotes(): Int {
        return self.numOfVotes;
    }
}
