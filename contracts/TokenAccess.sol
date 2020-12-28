// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/AccessManagement.sol";

contract TokenAccess is AccessManagement  {

  address minter;
  address burner;
  address admin;
  address pauser;

  event RoleAdminChanged(
    bytes32 indexed role, 
    bytes32 indexed previousAdminRole, 
    bytes32 indexed newAdminRole
  );

  event RoleGranted(
    bytes32 indexed role, 
    address indexed account, 
    address indexed sender
  );

  event RoleRevoked(
    bytes32 indexed role, 
    address indexed account, 
    address indexed sender
  );

  constructor() {
    admin = _msgSender();
    minter = _msgSender();
    burner = _msgSender();
    pauser = _msgSender();
  }

  function hasRole(bytes32 role, address account) public view returns (bool) {
    return _roles[role].members.contains(account);
  }

}