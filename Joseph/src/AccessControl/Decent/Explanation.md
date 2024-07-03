# Source: https://github.com/code-423n4/2024-01-decent-findings/issues/721

### Vulnerability Summary

**Impact**:
- The `setRouter` function in `DcntEth.sol` lacks access control, allowing anyone to set their own address as the router.
- This exposes the protocol to potential disruption, as the attacker can mint and burn tokens by bypassing the `onlyRouter` modifier.
- Additionally, `DecentEthRouter` would be unable to use `addLiquidityEth`, `removeLiquidityEth`, `addLiquidityWeth`, and `removeLiquidityWeth` functions.

### Code Snippets

#### `DcntEth.sol`

```solidity
function setRouter(address _router) external {
    router = _router;
}

modifier onlyRouter() {
    require(msg.sender == router, "Caller is not the router");
    _;
}
```

#### `DecentEthRouter.sol`

```solidity
function addLiquidityEth(...) external { ... }
function removeLiquidityEth(...) external { ... }
function addLiquidityWeth(...) external { ... }
function removeLiquidityWeth(...) external { ... }
```

### Issues Explained

- **Lack of Access Control in `setRouter`**:
  - The `setRouter` function allows anyone to set the router address without restriction.
  - This enables an attacker to call `setRouter(attackerAddress)` and then:
    - Call `mint(attackerAddress, anyAmount)` to mint any amount of tokens to themselves.
    - Call `burn(victimAddress, victimBalance)` to burn tokens from any victim's balance.

- **Impact on `DecentEthRouter`**:
  - Once an attacker sets their own address as the router, the legitimate `DecentEthRouter` cannot use its functions (`addLiquidityEth`, `removeLiquidityEth`, `addLiquidityWeth`, and `removeLiquidityWeth`).

### Proof of Concept

1. An attacker calls `setRouter(attackerAddress)`.
2. The attacker then calls:
   - `mint(attackerAddress, anyAmount)` to mint tokens to themselves.
   - `burn(victimAddress, victimBalance)` to burn tokens from any victim.

### Tools Used

- Manual review

### Recommended Mitigation Steps

- Add an `onlyOwner` modifier to the `setRouter` function to restrict its access to the contract owner:

    ```solidity
    function setRouter(address _router) external onlyOwner {
        router = _router;
    }
    ```

### Assessed Type

- Access Control