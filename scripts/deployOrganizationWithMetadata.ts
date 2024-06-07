import { toNano } from '@ton/core';
import { Repository } from '../wrappers/Repository';
import { NetworkProvider } from '@ton/blueprint';
import { repoId } from './constants';

export async function run(provider: NetworkProvider) {
    const repoContract = provider.open(await Repository.fromInit(repoId));

    console.log(repoContract.address);
    const organizationId = await repoContract.getNumOfOrganizations();

    await repoContract.send(
        provider.sender(),
        {
            value: toNano('0.25'),
        },
        {
            $$type: 'DeployOrganizationWithMetadata',
            metadata: {
                $$type: 'Metadata',
                name: 'HOleksii',
                description: 'My own organization',
                emoji: '🥖',
                website: 'https://github.com/holeksii',
            },
        },
    );

    console.log('organization address:', await repoContract.getOrganizationAddress(organizationId));
}
