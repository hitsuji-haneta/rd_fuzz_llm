// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

error AllowanceBelowZero();
error ApproveWithZeroAddress();
error BurnExceedsBalance();
error BurnFromZeroAddress();
error InsufficientAllowance();
error MintToZeroAddress();
error TransferAmountExceedsBalance();
error TransferZeroAddress();

contract SimpleERC20 is IERC20 {
    string internal _name;
    string internal _symbol;

    uint8 internal _decimals;
    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    // Miscellaneous constants
    uint256 internal constant UINT256_MAX = type(uint256).max;
    address internal constant ZERO_ADDRESS = address(0);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return _balances[_account];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        if (_from == ZERO_ADDRESS || _to == ZERO_ADDRESS) {
            revert TransferZeroAddress();
        }

        uint256 fromBalance = _balances[_from];

        if (fromBalance < _amount) {
            return false;
        }

        unchecked {
            _balances[_from] = fromBalance - _amount;
            _balances[_to] += _amount;
        }

        emit Transfer(_from, _to, _amount);
        return true;
    }

    function _mint(address _account, uint256 _amount) internal {
        if (_account == ZERO_ADDRESS) {
            revert MintToZeroAddress();
        }

        _totalSupply += _amount;

        unchecked {
            _balances[_account] += _amount;
        }

        emit Transfer(ZERO_ADDRESS, _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
        if (_account == ZERO_ADDRESS) {
            revert BurnFromZeroAddress();
        }

        uint256 accountBalance = _balances[_account];

        if (accountBalance < _amount) {
            revert BurnExceedsBalance();
        }

        unchecked {
            _balances[_account] = accountBalance - _amount;
            _totalSupply -= _amount;
        }

        emit Transfer(_account, ZERO_ADDRESS, _amount);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        return _transfer(_msgSender(), _to, _amount);
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _amount
    ) external returns (bool) {
        return _approve(_msgSender(), _spender, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        _spendAllowance(_from, _msgSender(), _amount);

        return _transfer(_from, _to, _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal returns (bool) {
        if (_owner == ZERO_ADDRESS || _spender == ZERO_ADDRESS) {
            revert ApproveWithZeroAddress();
        }

        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
        return true;
    }

    function _spendAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal returns (bool) {
        uint256 currentAllowance = allowance(_owner, _spender);

        if (currentAllowance != UINT256_MAX) {
            if (currentAllowance < _amount) {
                return false;
            }

            unchecked {
                _approve(_owner, _spender, currentAllowance - _amount);
            }
        }
        return true;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}
