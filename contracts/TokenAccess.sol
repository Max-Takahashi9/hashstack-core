// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/Access/AccessControl.sol";

contract TokenAccess{

  AccessControl private access;
  
  address private adminAddress;
  bytes32 private adminToken;

  address private minterAddress;
  address private burnerAddress;
  address private pauserAddress;

  bytes32 private minter;
  bytes32 private burner;
  bytes32 private pauser;


  constructor (address admin_, address minter_, address burner_, address pauser_) {
    adminAddress = admin_;
    minterAddress = _minter;
    burnerAddress = _burner;
    pauserAddress = pauser_;

    access._addAdmin(adminToken, adminAddress);
    access._addRole(minter, minterAddress);
    access._addRole(burner, burnerAddress);
    access._addRole(pauser, pauserAddress);
  }

  function removeRole(bytes32 role, address account) external onlyAdmin(adminToken,adminAddress)  {
    access._revokeRole(role, account);
  }
  function transferRole(bytes32 role, address oldAccount, address newAccount) external  {
    access.transferRole(role,oldAccount,newAccount) ;
  }

  function renounceRole(bytes32 role, address oldAccount) external {
    access.renounceRole(role, account);
  }

  function hasAdminRole(bytes32 role, address account) private view returns(bool) {
    require(access.hasAdminRole(role, account), "Does not have an admin role.");
  }

  modifier onlyAdmin()  {
    require(access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyPauser()  {
    require(access.hasRole(pauser, pauserAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyMinter() {
    require(access.hasRole(minter, minterAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyBurner() {
    require(access.hasRole(burner, burnerAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

}