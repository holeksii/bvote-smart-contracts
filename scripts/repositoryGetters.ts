import { NetworkProvider } from '@ton/blueprint';
import { Repository } from '../wrappers/Repository';
import { repoId } from './constants';

export async function run(provider: NetworkProvider) {
    const repository = await Repository.fromInit(repoId);
    const repoContract = provider.open(repository);

    console.log('repository address: ' + repoContract.address);
    console.log('owner address: ' + (await repoContract.getOwner()));
    console.log('numer of organizations: ' + (await repoContract.getNumOfOrganizations()));
    console.log("address of 0's index address: " + (await repoContract.getOrganizationAddress(0n)));
    console.log('deploy organization fee: ' + (await repoContract.getDeployOrganizationFee()));
}
