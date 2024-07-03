# Source: https://github.com/code-423n4/2023-06-lybra-findings/issues/704

### Vulnerability Summary

**Vulnerability Title**:
Incorrectly implemented modifiers in `LybraConfigurator.sol` allow any address to call functions that are supposed to be restricted.

**Impact**:
- The access control measures in the `LybraConfigurator` and `GovernanceTimelock` contracts are flawed. The modifiers `checkRole` and `onlyRole` call functions that return booleans to indicate whether the sender has the required role, but the return values are not checked. This means that the functions decorated by these modifiers are not properly protected.
- This would allow anybody to call sensitive functions that should be restricted.

### Code Snippets

#### `LybraConfigurator.sol`

```solidity
modifier onlyRole(bytes32 role) {
    GovernanceTimelock.checkOnlyRole(role, msg.sender);
    _;
}

modifier checkRole(bytes32 role) {
    GovernanceTimelock.checkRole(role, msg.sender);
    _;
}
```

#### `GovernanceTimelock.sol`

```solidity
function checkRole(bytes32 role, address _sender) public view returns (bool) {
    return hasRole(role, _sender) || hasRole(DAO, _sender);
}

function checkOnlyRole(bytes32 role, address _sender) public view returns (bool) {
    return hasRole(role, _sender);
}
```

### Issues Explained

- **Lack of Return Value Check**:
  - The `checkRole` and `checkOnlyRole` functions return booleans indicating whether the sender has the required role.
  - The `checkRole` and `onlyRole` modifiers call these functions but do not check the return value. Therefore, they do not enforce the access control properly.
  - Without checking the return value, any sender can potentially bypass the role checks, which can lead to unauthorized access and execution of critical functions.

### Proof of Concept

- The impacted lines of code in `LybraConfigurator.sol` do not provide the necessary protection:

    ```solidity
    modifier onlyRole(bytes32 role) {
        GovernanceTimelock.checkOnlyRole(role, msg.sender);
        _;
    }

    modifier checkRole(bytes32 role) {
        GovernanceTimelock.checkRole(role, msg.sender);
        _;
    }
    ```

- This results in the functions decorated by these modifiers not being properly secured against unauthorized access.

### Tools Used

- Manual review

### Recommended Mitigation Steps

- Modify the `onlyRole` and `checkRole` modifiers to include `require` statements that check the boolean return value of the `checkOnlyRole` and `checkRole` functions:

    ```solidity
    modifier onlyRole(bytes32 role) {
        require(GovernanceTimelock.checkOnlyRole(role, msg.sender), "Not Authorized");
        _;
    }

    modifier checkRole(bytes32 role) {
        require(GovernanceTimelock.checkRole(role, msg.sender), "Not Authorized");
        _;
    }
    ```

### Assessed Type

- Access Control