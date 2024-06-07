import { address } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { Voting } from '../wrappers/Voting';

export async function run(provider: NetworkProvider) {
    const votingContract = provider.open(
        Voting.fromAddress(address('EQDV3bxXMkrAL8KX1q21Ga_8LR-RpzLdd4D6jNVqneMuVyFO')),
    );

    console.log('voting address: ' + votingContract.address);
    console.log('metadata: ' + (await votingContract.getMetadata()));
    console.log('all info: ' + (await votingContract.getAllInfo()));
    console.log('candidates: ' + (await votingContract.getCandidates()).candidates.values());
}
