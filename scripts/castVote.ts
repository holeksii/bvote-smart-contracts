import { toNano } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { Organization } from '../wrappers/Organization';
import { Voting } from '../wrappers/Voting';
import { Repository } from '../wrappers/Repository';
import { NewVoteArray } from '../wrappers/Arrays';

export async function run(provider: NetworkProvider) {
    const repositoryAddress = (await Repository.fromInit(0n)).address;
    const organizationAddress = (await Organization.fromInit(repositoryAddress, 0n)).address;
    const voting = provider.open(await Voting.fromInit(organizationAddress, 0n));

    const votes = NewVoteArray([
        [0n, 1n],
    ]);

    await voting.send(
        provider.sender(),
        {
            value: toNano('0.1'),
        },
        {
            $$type: 'DeployAndCastVote',
            candidateInd: 0n,
            numOfVotes: 1n,
        },
    );
}
