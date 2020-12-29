// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/Access/AccessControl.sol";

contract TokenAccess is AccessControl  {

  address private minter;
  address private burner;
  address private admin;
  address private pauser;

  bytes32 adminToken;
  constructor (address admin_, address minter_, address burner_, address pauser_) {
    
  }

}