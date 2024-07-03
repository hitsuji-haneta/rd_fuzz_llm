## Vulnerability Title
No access control check in payableCall()
https://github.com/code-423n4/2023-09-maia/blob/f5ba4de628836b2a29f9b5fff59499690008c463/src/VirtualAccount.sol#L85-L112

## Vulnerability Details or Impact
The virtualAccount.sol handles three main things which are the ERC20, ERC721 and ERC1155 tokens and these are tokens of different kinds. In the payableCall(), it takes in a PayableCall[] in its parameter, and this PayableCall[] can be constructed in such a way that can lead to the loss of these tokens in the contract and this is because there is no access control check in the function and can thereby make anybody call the function and execute any input of their choice leading to loss of funds.


## Lines of Code
As seen below, PayableCall struct has a target address as well as a callData that can be manipulated. For example, the target address of any ERC20 token held in the virtual account can be passed in as the address with a maliciously crafted callData to either transfer or approve the tokens to the hacker's address
```solidity
    function payableCall(PayableCall[] calldata calls) public payable returns (bytes[] memory returnData) {
        uint256 valAccumulator;
        uint256 length = calls.length;
        returnData = new bytes[](length);
        PayableCall calldata _call;
        for (uint256 i = 0; i < length;) {
            _call = calls[i];
            uint256 val = _call.value;
            // Humanity will be a Type V Kardashev Civilization before this overflows - andreas
            // ~ 10^25 Wei in existence << ~ 10^76 size uint fits in a uint256
            unchecked {
                valAccumulator += val;
            }

            bool success;

            if (isContract(_call.target)) (success, returnData[i]) = _call.target.call{value: val}(_call.callData);

            if (!success) revert CallFailed();

            unchecked {
                ++i;
            }
        }

        // Finally, make sure the msg.value = SUM(call[0...i].value)
        if (msg.value != valAccumulator) revert CallFailed();
    }
 struct PayableCall {
    address target;
    bytes callData;
    uint256 value;
  }
```

## Mitigation
Add the "requiresApprovedCaller" modifier to the function payableCall to ensure that a valid check is done.