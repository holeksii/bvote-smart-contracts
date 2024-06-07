import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Organization } from '../wrappers/Organization';
import '@ton/test-utils';

describe('Organization', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let organization: SandboxContract<Organization>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        organization = blockchain.openContract(await Organization.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await organization.send(
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
            to: organization.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and organization are ready to use
    });
});
