import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Voting } from '../wrappers/Voting';
import '@ton/test-utils';

describe('Voting', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let voting: SandboxContract<Voting>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        voting = blockchain.openContract(await Voting.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await voting.send(
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
            to: voting.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and voting are ready to use
    });
});
