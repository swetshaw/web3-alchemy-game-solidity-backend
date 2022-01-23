async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const gameContractFactory = await hre.ethers.getContractFactory(
    'GameContract'
  );
  const gameContract = await gameContractFactory.deploy([
    'https://ipfs.io/ipfs/QmRXPhTriZL4Q4NhFsn66zTCfiavCHEhLMkt8VE6V65yap?filename=air.json',
    'https://ipfs.io/ipfs/QmPWv14qooESXY6SyguKcTwDPPGvHnshubz2NPhDjbsMwT?filename=water.json',
    'https://ipfs.io/ipfs/QmYfmHvCZsxgzPWMUynMDNGYpAu4VYCU2R6mMg37hX2E25?filename=fire.json',
    'https://ipfs.io/ipfs/Qmd3DYaYo7hMeLaHzUeoZ72A3ogk8fZ4xyrnPEqarT9CjS?filename=earth.json',
  ]);

  await gameContract.deployed();
  console.log('Contract deployed to: ', gameContract.address);

  const characters = await gameContract.getDefaultCharacters();
  console.log('All characters', characters);

  let txn;
  txn = await gameContract.mintNFT(0);
  await txn.wait();

  console.log('Minted NFT #1 successfuly!!');

  txn = await gameContract.mintNFT(1);
  await txn.wait();
  console.log('Minted NFT #2 successfuly!!');

  txn = await gameContract.isOwner(1);
  await txn.wait();
  console.log('Is owner', txn);

  txn = await gameContract.isOwner(2);
  console.log('Is owner', txn);

  txn = await gameContract.isOwner(3);
  console.log('Is owner', txn);

  txn = await gameContract.combineNFTs(1, 2);

  txn = await gameContract.getUserNFTS();
  console.log('NFTS -->', txn);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
