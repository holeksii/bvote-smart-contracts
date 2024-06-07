import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { HiddenVoting } from '../wrappers/HiddenVoting';
import '@ton/test-utils';

describe('HiddenVoting', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let hiddenVoting: SandboxContract<HiddenVoting>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        hiddenVoting = blockchain.openContract(await HiddenVoting.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await hiddenVoting.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: hiddenVoting.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and hiddenVoting are ready to use
    });
});
