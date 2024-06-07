import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Metadata, Repository } from '../wrappers/Repository';
import '@ton/test-utils';
import { Organization } from '../wrappers/Organization';

describe('Repository', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let repository: SandboxContract<Repository>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        repository = blockchain.openContract(await Repository.fromInit(0n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await repository.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: repository.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and repository are ready to use
    });

    it('should deploy organization', async () => {
        const myMetadata: Metadata = {
            $$type: 'Metadata',
            name: 'HOleksii',
            description: 'My own organization',
            emoji: '🥖',
            website: 'https://github.com/holeksii',
        };

        const deployResult = await repository.send(
            deployer.getSender(),
            {
                value: toNano('0.3'),
            },
            {
                $$type: 'DeployOrganizationWithMetadata',
                metadata: myMetadata,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: repository.address,
            success: true,
        });

        expect((await repository.getNumOfOrganizations()).toString()).toEqual(1n.toString());

        const organizationAddress = await repository.getOrganizationAddress(0n);
        const organization = blockchain.openContract(Organization.fromAddress(organizationAddress));
        const organizationMetadata = await organization.getMetadata();
        expect(organizationMetadata).toEqual(myMetadata);
    });
});
