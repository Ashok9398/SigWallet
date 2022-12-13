const {ethers} = require('hardhat');
const {expect} = require('chai');
const { isCallTrace } = require('hardhat/internal/hardhat-network/stack-traces/message-trace');

let accounts = [];
let multisigwallet;
let signers;
describe("Checks for MultiSigWallet",()=>{
    before("Deploy and Accounts",async()=>{
        signers = await ethers.getSigners();
        for(let i =0;i<5;i++){
            accounts.push(signers[i].address);
        }
        console.log(accounts.length);
        multiSigWallet = await ethers.getContractFactory("MultiSigWallet");
        multisigwallet = await multiSigWallet.deploy(accounts);
        
    })
    it ("checks for owners",async()=>{
        const owner = await multisigwallet.owners(0);

        expect(owner).to.equal(accounts[0]);
    })
    it("retrieves quorum",async()=>{
       
        console.log(await multisigwallet.quorum());
    })
    it("Checks for add owner",async()=>{

        expect(await multisigwallet.addOwner(signers[6].address)).to.emit(multisigwallet,"OwnerAddition").withArgs(signers[6].address);
        expect(await multisigwallet.isOwner(signers[6].address)).to.equal(true);
        console.log(await multisigwallet.quorum());
    })
    it("Checks for remove Owner",async()=>{
        expect(await multisigwallet.removeOwner(signers[1].address)).to.emit(multisigwallet,'OwnerRemoval').withArgs(accounts[1]);
        expect(await multisigwallet.isOwner(signers[1].address)).to.equal(false);
        console.log(await multisigwallet.quorum());
    })
    it("it Checks for owner transfer function ",async()=>{
        expect(await multisigwallet.isOwner(signers[6].address)).to.equal(true);
        expect(await multisigwallet.transferOwner(signers[6].address,signers[5].address)).to.emit(multisigwallet,'OwnerAddition').withArgs(signers[5].address);
        expect(await multisigwallet.isOwner(signers[6].address)).to.equal(false);
        expect(await multisigwallet.isOwner(signers[5].address)).to.equal(true);
    })
    it("checks for submission function ",async()=>{
        expect(await multisigwallet.submitTransaction(signers[8].address ,10 ,1010)).to.emit(multisigwallet,"Submission").withArgs(0);
        expect(await multisigwallet.transactionCount()).to.equal(1);
    })
    it("Checks for confirmation transcation function",async()=>{
        expect(await multisigwallet.connect(signers[2]).confirmTransaction(0)).to.emit(multisigwallet,'Confirmation').withArgs(signers[2].address,0);
        expect(await multisigwallet.confirmations(0,accounts[2])).to.equal(true);
    })
    it("Checks for executeTransaction",async()=>{
        console.log(await multisigwallet.isReached());
        await multisigwallet.connect(signers[3]).confirmTransaction(0);
        await multisigwallet.connect(signers[4]).confirmTransaction(0);
        expect(await multisigwallet.executeTransaction(0)).to.emit(multisigwallet,"Exection").withArgs(0);
        console.log(await multisigwallet.isReached());
        
    })
   
})  