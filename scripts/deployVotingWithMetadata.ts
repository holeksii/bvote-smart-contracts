import { address, toNano } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { Organization } from '../wrappers/Organization';
import { Repository } from '../wrappers/Repository';
import { NewCandidateArray } from '../wrappers/Arrays';
import { repoId } from './constants';

export async function run(provider: NetworkProvider) {
    const repositoryAddress = (await Repository.fromInit(repoId)).address;
    const organizationContract = provider.open(await Organization.fromInit(repositoryAddress, 0n));

    const candidates = NewCandidateArray([
        ['Alice', 'Alice is a good person'],
        ['Bob', 'Bob is a good person'],
        ['Charlie', 'Charlie is a good person'],
    ]);
    const votingId = await organizationContract.getNumOfVotings();

    await organizationContract.send(
        provider.sender(),
        {
            value: toNano('0.1'),
        },
        {
            $$type: 'DeployVotingWithMetadata',
            candidates: candidates,
            voteFee: 0n,
            votesPerCandidate: 1n,
            startTime: 0n,
            timeToLive: 2147483645n,
            metadata: {
                $$type: 'Metadata',
                name: "HOleksii's voting",
                description: 'My first voting',
                emoji: '🗿',
                website: "",
            },
        },
    );

    console.log('voting address:', await organizationContract.getVotingAddress(votingId));
}
