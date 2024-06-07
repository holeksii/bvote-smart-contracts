import { toNano } from '@ton/core';
import { HiddenVoting } from '../wrappers/HiddenVoting';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const hiddenVoting = provider.open(await HiddenVoting.fromInit());

    await hiddenVoting.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(hiddenVoting.address);

    // run methods on `hiddenVoting`
}
