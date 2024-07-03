// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TransferHelper.sol";
import "./MockERC20.sol";

contract PendlePowerFarmToken is SimpleERC20, TransferHelper {
    address UNDERLYING_PENDLE_MARKET;

    constructor(address _token) {
        UNDERLYING_PENDLE_MARKET = _token;
    }

    function addCompoundRewards(uint256 _amount) external {
        if (_amount == 0) {
            revert();
        }

        _safeTransferFrom(
            UNDERLYING_PENDLE_MARKET,
            msg.sender,
            address(this),
            _amount
        );
    }
}
