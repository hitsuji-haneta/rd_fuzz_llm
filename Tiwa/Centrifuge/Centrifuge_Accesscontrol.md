## Vulnerability Title
You can deposit for other users really small amount to DoS them
https://github.com/code-423n4/2023-09-centrifuge/blob/512e7a71ebd9ae76384f837204216f26380c9f91/src/LiquidityPool.sol


## Vulnerability Details or Impact
Deposit and mint under LiquidityPool lack access control, which enables any user to proceed the mint/deposit for another user. Attacker can deposit (this does not require tokens) some wai before users TX to DoS the deposit.
deposit() and mint() do processDeposit/processMint which are the secondary functions to the requests. These function do not take any value in the form of tokens, but only send shares to the receivers. This means they can be called for free.

With this an attacker who wants to DoS a user, can wait him to make the request to deposit and on the next epoch front run him by calling deposit with something small like 1 wei. Afterwards when the user calls deposit, his TX will inevitable revert, as he will not have enough balance for the full deposit.


## Lines of Code
 ```function deposit(uint256 assets, address receiver) public returns (uint256 shares) {
        shares = investmentManager.processDeposit(receiver, assets);
        emit Deposit(address(this), receiver, assets, shares);
    }
 
 function mint(uint256 shares, address receiver) public returns (uint256 assets) {
        assets = investmentManager.processMint(receiver, shares);
        emit Deposit(address(this), receiver, assets, shares);
    }
```

## Mitigation
Have some access control modifiers like 'withApproval' like it is used in redeem()
```function redeem(uint256 shares, address receiver, address owner)
        public
        withApproval(owner)
        returns (uint256 assets)
    {
        uint256 currencyPayout = investmentManager.processRedeem(shares, receiver, owner);
        emit Withdraw(address(this), receiver, owner, currencyPayout, shares);
        return currencyPayout;
    }
```