// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./MockERC20.sol";

contract CallOptionalReturn {
    /**
     * @dev Helper function to do low-level call
     */
    function _callOptionalReturn(
        address token,
        bytes memory data
    ) internal returns (bool call) {
        (bool success, bytes memory returndata) = token.call(data);

        bool results = returndata.length == 0 || abi.decode(returndata, (bool));

        if (success == false) {
            revert();
        }

        call = success && results && token.code.length > 0;
    }
}

contract TransferHelper is CallOptionalReturn {
    /**
     * @dev
     * Allows to execute safe transfer for a token
     */
    function _safeTransfer(
        address _token,
        address _to,
        uint256 _value
    ) internal {
        _callOptionalReturn(
            _token,
            abi.encodeWithSelector(IERC20.transfer.selector, _to, _value)
        );
    }

    /**
     * @dev
     * Allows to execute safe transferFrom for a token
     */
    function _safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    ) internal {
        _callOptionalReturn(
            _token,
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                _from,
                _to,
                _value
            )
        );
    }
}
