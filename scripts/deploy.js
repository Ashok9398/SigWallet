async function main() {
    const signers = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", signers[0].address);
  
    console.log("Account balance:", (await signers[0].getBalance()).toString());
    let accounts=[];
    
    for(let i =0;i<4;i++){
        accounts.push(signers[0].address);
    }
  
    const multiSigWallet = await ethers.getContractFactory("MultiSigWallet");
    const multisigwallet = await multiSigWallet.deploy(accounts);
  
    console.log("Wallet address:", multisigwallet.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    //wallet address :  0xD0448a0ceA4C286554Cf30F1dA931aBC953a4c9B;