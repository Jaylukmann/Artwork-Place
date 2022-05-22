# Celo Artwork-Place Dapp
![]()

## Description
This is a very simple artworkplace dapp where users can:
* Host artworks but not buy their own artwork.
* See artworks hosted by you and others on the Celo Blockchain.
* Purchase artworks with cUSD and pay the owner
* Add your own artworks to the dapp as well as edit and delete your artwork.
 

## Live Demo
[Artwork-Place]([Artwork-Place](https://jaylukmann.github.io/Artwork-Place/src/index.html))

## Usage

### Requirements
1. Install the [CeloExtensionWallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en) from the Google Chrome Store.
2. Create a wallet.
3. Go to [https://celo.org/developers/faucet](https://celo.org/developers/faucet) and get tokens for the alfajores testnet.
4. Switch to the alfajores testnet in the CeloExtensionWallet.

### [Artwork-Place](https://jaylukmann.github.io/Artwork-Place/src/index.html)
1. Create an artwork and check if you can buy your own artwork. It should fail.
2. Create a second account in your extension wallet and send them cUSD tokens.
3. Buy artwork with secondary account.
4. Check if balance of first account increased by 95% as the contract owner receives 5% commission
5.Check if the artwork owner can edit and delete the his artwork. He should.


## Project Setup

### Install
```
npm install
```

### Start
```
npm run dev
```

### Build
```
npm run build
