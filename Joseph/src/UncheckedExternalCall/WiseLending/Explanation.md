# Source: https://github.com/code-423n4/2024-02-wise-lending-findings/issues/245

### Vulnerability Summary

**Impact**:
- The `CallOptionalReturn.sol` contract provides the `_callOptionalReturn()` function to interact with token contracts, returning a boolean or reverting based on the scenario. However, it fails to handle cases where ERC20 tokens return `false` instead of reverting.
- This issue affects `ApprovalHelper` and `TransferHelper`, leading to unsafe `approve`, `transfer`, and `transferFrom` operations.

### Code Snippets

#### `CallOptionalReturn.sol`

```solidity
(bool success, bytes memory returndata) = token.call(data);
bool results = returndata.length == 0 || abi.decode(returndata, (bool));

if (!success) {
    revert();
}

call = success && results && token.code.length > 0;
```

#### `ApprovalHelper.sol`

```solidity
function _safeApprove(address _token, address _spender, uint256 _value) internal {
    _callOptionalReturn(
        _token,
        abi.encodeWithSelector(IERC20.approve.selector, _spender, _value)
    );
}
```

#### `TransferHelper.sol`

```solidity
function _safeTransfer(address _token, address _to, uint256 _value) internal {
    _callOptionalReturn(
        _token,
        abi.encodeWithSelector(IERC20.transfer.selector, _to, _value)
    );
}

function _safeTransferFrom(address _token, address _from, address _to, uint256 _value) internal {
    _callOptionalReturn(
        _token,
        abi.encodeWithSelector(IERC20.transferFrom.selector, _from, _to, _value)
    );
}
```

### Issues Explained

1. **CallOptionalReturn**:
   - If an ERC20 token returns `false` instead of reverting, the function does not revert. The result is checked as `bool results` but not handled appropriately in the calling context.
   - The `_callOptionalReturn()` function does not adequately handle the `false` return case, leading to potential issues when interacting with non-standard ERC20 tokens.

2. **ApprovalHelper and TransferHelper**:
   - The `_safeApprove` function in `ApprovalHelper` and `_safeTransfer` and `_safeTransferFrom` functions in `TransferHelper` do not check the boolean returned by `_callOptionalReturn`.
   - This oversight can result in operations proceeding as if they succeeded, even when they have failed according to the ERC20 token's `false` return value.

### Proof of Concept

- According to the [EIP-20 standard](https://eips.ethereum.org/EIPS/eip-20):
  - Callers **MUST** handle `false` returns from token functions.
  - Callers **MUST NOT** assume that `false` is never returned.
- The current implementation in `CallOptionalReturn.sol`, `ApprovalHelper.sol`, and `TransferHelper.sol` does not comply with this requirement.

### Recommended Mitigation Steps

- Modify `_callOptionalReturn()` to properly handle and propagate the `false` return value.
- Ensure that `ApprovalHelper` and `TransferHelper` check the boolean return value from `_callOptionalReturn()` to handle unsuccessful operations appropriately.