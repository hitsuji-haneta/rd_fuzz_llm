<div align="center">
    <img alt="LayerZero" src="resources/LayerZeroLogo.png"/>
</div>

---

# LayerZero Omnichain Contract Examples

* Formal audit(s) (May 21, 2022) can be found in /audit

 ### Install & Run tests
```shell
yarn install
npx hardhat test 
```

* The code in the `/contracts` folder demonstrates LayerZero behaviours.
* `NonblockingLzApp` is a great contract to extend. Take a look at how `OmniCounter` overrides `_nonblockingLzReceive` and `_LzReceive` to easily handle messaging. There are also example for `OFT` and `ONFT` which illustrate erc20 and erc721 cross chain functionality.
* Always audit your own code and test extensively on `testnet` before going to mainnet 🙏

> The examples below use two chains, however you could substitute any LayerZero supported chain! 

# OmnichainFungibleToken (OFT)

## About OFTV2
```shell
NOTE: the OFTV2 uses uint64 to encode value transfer for compatability of aptos and solana. 

The deployer is expected to set a lower decimal points like 6 or 8. 

If the decimal point is 18, then uint64 can only represent approximately 18 tokens (uint64.max ~= 18 * 10^18).
```

## Deploy Setup
1. Add a .env file (to the root project directory) with your MNEMONIC="" and fund your wallet in order to deploy!
2. Follow any of the tutorials below

## OFTV2Mock.sol - an omnichain ERC20

> WARNING: **You must perform the setTrustedRemote() (step 2). This is a mock deployment that auto mints tokens to msg.sender**

1. Deploy two contracts:
```angular2html
npx hardhat --network goerli deploy --tags OFTV2Mock
npx hardhat --network fuji deploy --tags OFTV2Mock
```
2. Set the "trusted remotes" (ie: your contracts) so each of them can receive messages from one another, and `only` one another.
```angular2html
npx hardhat --network goerli setTrustedRemote --target-network fuji --contract OFTV2Mock
npx hardhat --network fuji setTrustedRemote --target-network goerli --contract OFTV2Mock
```
3. Send tokens from goerli to fuji
```angular2html
npx hardhat --network goerli oftv2Send --target-network fuji --qty 42 --contract OFTV2Mock
```
 Pro-tip: Check the ERC20 transactions tab of the destination chain block explorer and await your tokens!

# OmnichainNonFungibleToken721 (ONFT721)

This ONFT contract allows minting of `nftId`s on separate chains. To ensure two chains can not mint the same `nfId` each contract on each chain is only allowed to mint`nftIds` in certain ranges.
Check `constants/onftArgs.json` for the specific test configuration used in this demo.
## ONFT721Mock.sol 

> WARNING: **You must perform the setTrustedRemote() (step 2).**

1. Deploy two contracts:
```angular2html
 npx hardhat --network bsc-testnet deploy --tags ONFT721Mock
 npx hardhat --network fuji deploy --tags ONFT721Mock
```
2. Set the "trusted remotes", so each contract can send & receive messages from one another, and `only` one another.
```angular2html
npx hardhat --network bsc-testnet setTrustedRemote --target-network fuji --contract ONFT721Mock
npx hardhat --network fuji setTrustedRemote --target-network bsc-testnet --contract ONFT721Mock
```
3. Set the min gas required on the destination
```angular2html
npx hardhat --network bsc-testnet setMinDstGas --target-network fuji --contract ONFT721Mock --packet-type 1 --min-gas 100000
npx hardhat --network fuji setMinDstGas --target-network bsc-testnet --contract ONFT721Mock --packet-type 1 --min-gas 100000
```
4. Mint an NFT on each chain!
```angular2html
npx hardhat --network bsc-testnet onftMint --contract ONFT721Mock
npx hardhat --network fuji onftMint --contract ONFT721Mock
```
5. [Optional] Show the token owner(s)
```angular2html
npx hardhat --network bsc-testnet ownerOf --token-id 1 --contract ONFT721Mock
npx hardhat --network fuji ownerOf --token-id 11 --contract ONFT721Mock
```
6. Send ONFT across chains
```angular2html
npx hardhat --network bsc-testnet onftSend --target-network fuji --token-id 1 --contract ONFT721Mock
npx hardhat --network fuji onftSend --target-network bsc-testnet --token-id 11 --contract ONFT721Mock 
```
7. Verify your token no longer exists in your wallet on the source chain & wait for it to reach the destination side.
```angular2html
npx hardhat --network bsc-testnet ownerOf --token-id 1 --contract ONFT721Mock
npx hardhat --network fuji ownerOf --token-id 1 --contract ONFT721Mock
```


# OmniCounter.sol

OmniCounter is a simple contract with a counter. You can only *remotely* increment the counter!

1. Deploy both OmniCounters:

```
npx hardhat --network bsc-testnet deploy --tags OmniCounter
npx hardhat --network fuji deploy --tags OmniCounter
````

2. Set the remote addresses, so each contract can receive messages
```angular2html
npx hardhat --network bsc-testnet setTrustedRemote --target-network fuji --contract OmniCounter
npx hardhat --network fuji setTrustedRemote --target-network bsc-testnet --contract OmniCounter
```
3. Send a cross chain message from `bsc-testnet` to `fuji` !
```angular2html
npx hardhat --network bsc-testnet incrementCounter --target-network fuji
```

Optionally use this command in a separate terminal to watch the counter increment in real-time.
```
npx hardhat --network fuji ocPoll    
```

# Check your setTrustedRemote's are wired up correctly
Just use our checkWireUpAll task to check if your contracts are wired up correctly. You can use it on the example contracts deployed above.
1) UniversalONFT
```angular2html
npx hardhat checkWireUpAll --e testnet --contract ONFT721Mock
```
2) OmniCounter
```angular2html
npx hardhat checkWireUpAll --e testnet --contract OmniCounter
```

### See some examples in `/contracts`  🙌

Many of the example contracts make use of LayerZeroEndpointMock.sol which is a nice way to test LayerZero locally!

### For further reading, and a list of endpoint ids and deployed LayerZero contract addresses please take a look at the Gitbook here: https://layerzero.gitbook.io/


# See testnet and mainnet chainIds and addresses, and the format for connecting contracts on different chains:
 https://github.com/LayerZero-Labs/set-trusted-remotes 
 https://layerzero.gitbook.io/docs/technical-reference/testnet/testnet-addresses
 https://layerzero.gitbook.io/docs/technical-reference/mainnet/supported-chain-ids


## Most recently tested with node version `16.13.1` 

