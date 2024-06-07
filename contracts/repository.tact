import "@stdlib/deploy";
import "@stdlib/ownable";
import "./util/repository_messages.tact";
import "./util/admin.tact";
import "./organization.tact";

contract Repository with Deployable, Ownable {

    const MIN_TON_TO_LIVE: Int = ton("0.1");

    owner: Address;
    repositoryId: Int as uint64;
    numOfOrganizations: Int as uint64;
    deployOrganizationFee: Int as uint64;

    init(repositoryId: Int) {
        self.owner = sender();
        self.repositoryId = repositoryId;
        self.numOfOrganizations = 0;  
        self.deployOrganizationFee = ton("1");
    }

    receive() {}

    receive("deployOrg") {
        require(context().value >= self.deployOrganizationFee + self.MIN_TON_TO_LIVE, "Insufficient funds to deploy organization");

        let init: StateInit = initOf Organization(myAddress(), self.numOfOrganizations);
        let organization: Address = contractAddress(init);

        send(SendParameters{
            to: organization,
            value: 0, 
            bounce: true,
            mode: SendRemainingValue,
            body: InitOrganization{owner: sender()}.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive(msg: DeployOrganizationWithMetadata) {
        require(context().value >= self.deployOrganizationFee + self.MIN_TON_TO_LIVE, "Insufficient funds to deploy organization");

        let init: StateInit = initOf Organization(myAddress(), self.numOfOrganizations);
        let organization: Address = contractAddress(init);

        send(SendParameters{
            to: organization,
            value: 0,
            bounce: false,
            mode: SendRemainingValue,
            body: InitOrganizationWithMetadata{
                owner: sender(),
                metadata: msg.metadata
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive("deployOrgOk") {
        self.numOfOrganizations += 1;
    }

    receive(msg: SetDeployOrgFee) {
        self.requireOwner();
        self.deployOrganizationFee = msg.newFee;
    }

    receive(msg: TransferOwnership) {
        self.requireOwner();
        self.owner = msg.newOwner;
    }

    receive("withdrawAll"){
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: 0,
            mode: (SendRemainingBalance + SendIgnoreErrors)
        });
    }

    receive("withdrawSafe"){
        self.requireOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - self.MIN_TON_TO_LIVE,
            mode: 0
        });
    }

    receive(msg: Withdraw) {
        require(sender() == self.owner, "Only deployer is allowed to withdraw");
        let amount: Int = min(msg.amount, myBalance() - context().value - self.MIN_TON_TO_LIVE);
        require(amount > 0, "Insufficient balance");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: amount,
            mode: SendRemainingValue + SendIgnoreErrors
        });
    }

    get fun numOfOrganizations(): Int {
        return self.numOfOrganizations;
    }

    get fun deployOrganizationFee(): Int {
        return self.deployOrganizationFee;
    }

    get fun deployOrganizationFeePlusTonToLive(): Int {
        return self.deployOrganizationFee + self.MIN_TON_TO_LIVE;
    }

    get fun organizationAddress(organizationId: Int): Address {
        let init: StateInit = initOf Organization(myAddress(), organizationId);
        return contractAddress(init);
    }

    get fun lastOrganizationAddress(): Address {
        let init: StateInit = initOf Organization(myAddress(), self.numOfOrganizations - 1);
        return contractAddress(init);
    }
}
