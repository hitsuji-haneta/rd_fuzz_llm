# Source : https://github.com/code-423n4/2023-08-goodentry-findings/issues/473

# Cannot be found through fuzzing

### Vulnerability Summary

**Impact**:
- Ether swaps conducted with the `V3Proxy` would be lost to another user forever.
- This is due to one major issues:
  1. Unchecked return value.
 
**Proof of Concept**:

The function `swapExactTokensForETH` contains the following issues:

1. **Unchecked Return Value**: 
   - The function attempts to send Ether using `payable(msg.sender).call{value: amounts[1]}("")`.
   - If the `msg.sender` is a contract that lacks a receive or fallback function, the transaction does not revert but returns false, leaving ETH in the contract.

 
### Code Snippet

```solidity
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) payable external returns (uint[] memory amounts) {
    require(path.length == 2, "Direct swap only");
    require(path[1] == ROUTER.WETH9(), "Invalid path");
    ERC20 ogInAsset = ERC20(path[0]);
    ogInAsset.safeTransferFrom(msg.sender, address(this), amountIn);
    ogInAsset.safeApprove(address(ROUTER), amountIn);
    amounts = new uint ;
    amounts[0] = amountIn;         
    amounts[1] = ROUTER.exactInputSingle(ISwapRouter.ExactInputSingleParams(path[0], path[1], feeTier, address(this), deadline, amountIn, amountOutMin, 0));
    ogInAsset.safeApprove(address(ROUTER), 0); 
    IWETH9 weth = IWETH9(ROUTER.WETH9());
    acceptPayable = true;
    weth.withdraw(amounts[1]);
    acceptPayable = false;
    payable(msg.sender).call{value: amounts[1]}("");
    emit Swap(msg.sender, path[0], path[1], amounts[0], amounts[1]);                 
}
```

 

1. **Unchecked Return Value**:
   - When `payable(msg.sender).call{value: amounts[1]}("")` is used, the transaction may fail but the failure is not checked. If the calling contract lacks a receive or fallback function, the ETH remains in the contract.

 

### Recommended Mitigation Steps

1. Check the boolean value returned by the `call()` method to ensure the transfer succeeded.
 
 

### Tools Used

- Manual Review