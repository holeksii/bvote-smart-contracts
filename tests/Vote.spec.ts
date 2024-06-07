import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Vote } from '../wrappers/Vote';
import '@ton/test-utils';

describe('Vote', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let vote: SandboxContract<Vote>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        vote = blockchain.openContract(await Vote.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await vote.send(
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
            to: vote.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and vote are ready to use
    });
});
