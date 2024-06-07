import { Address } from '@ton/core';
import { TonClient } from '@ton/ton';
import { Repository } from '../build/Repository/tact_Repository';


function minOfTwoBigInt(a: bigint, b: bigint): bigint {
    return a < b ? a : b;
}

export async function getOrganizationsAddress(
    tonClient: TonClient,
    repoId: bigint,
    from: bigint,
    num: bigint,
): Promise<Address[] | undefined> {
    const repo = await Repository.fromInit(repoId);
    const repoProvider = tonClient.provider(repo.address);
    const repoContract = repoProvider.open(repo);

    if (await tonClient.isContractDeployed(repo.address)) {
        const end = minOfTwoBigInt(from + num, await repoContract.getNumOfOrganizations());
        const orgs = [];
        for (let i = from; i < end; i++) {
            orgs.push(await repoContract.getOrganizationAddress(i));
        }
        return orgs;
    }
    return undefined;
}

export async function getOrganizationAddress(
    tonClient: TonClient,
    repoId: bigint,
    orgId: bigint,
): Promise<Address | undefined> {
    const repo = await Repository.fromInit(repoId);
    const repoProvider = tonClient.provider(repo.address);
    const repoContract = repoProvider.open(repo);

    if (await tonClient.isContractDeployed(repo.address)) {
        return await repoContract.getOrganizationAddress(orgId);
    }
    return undefined;
}

export async function getLastOrganizationAddress(tonClient: TonClient, repoId: bigint): Promise<Address | undefined> {
    const repo = await Repository.fromInit(repoId);
    const repoProvider = tonClient.provider(repo.address);
    const repoContract = repoProvider.open(repo);

    if (await tonClient.isContractDeployed(repo.address)) {
        return await repoContract.getLastOrganizationAddress();
    }
    return undefined;
}

export async function getOrganizationsCount(tonClient: TonClient, repoId: bigint): Promise<bigint | undefined> {
    const repo = await Repository.fromInit(repoId);
    const repoProvider = tonClient.provider(repo.address);
    const repoContract = repoProvider.open(repo);

    if (await tonClient.isContractDeployed(repo.address)) {
        return await repoContract.getNumOfOrganizations();
    }
    return undefined;
}

export * from '../build/Repository/tact_Repository';
