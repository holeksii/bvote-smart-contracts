import { Repository } from '../wrappers/Repository';
import { NetworkProvider } from '@ton/blueprint';
import { repoId } from './constants';
import { toNano } from '@ton/core';

export async function run(provider: NetworkProvider) {
    const repo = await Repository.fromInit(repoId);
    const repositoryContract = provider.open(repo);

    console.log('repository address:', repositoryContract.address);

    await repositoryContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        },
    );

    await provider.waitForDeploy(repositoryContract.address, 10, 1000);
}
